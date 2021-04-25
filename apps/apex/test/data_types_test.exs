defmodule DataTypesTest do
  use ExUnit.Case
  use PropCheck

  # https://www.h-schmidt.net/FloatConverter/IEEE754.html
  test "static examples of float32" do
    <<a, b, c, d>> = <<0::1, 124::8, 2_097_152::23>>
    {result, <<1, 2, 3>>} = F1.DataTypes.float32({%{}, <<d, c, b, a, 1, 2, 3>>}, :result)
    assert result[:result] == 0.15625

    <<a, b, c, d>> = <<1::1, 124::8, 2_097_152::23>>
    {result, <<21>>} = F1.DataTypes.float32({%{}, <<d, c, b, a, 21>>}, :result)
    assert result[:result] == -0.15625

    <<a, b, c, d>> = <<0::1, 138::8, 3_839_686::23>>
    {result, <<>>} = F1.DataTypes.float32({%{}, <<d, c, b, a>>}, :result)
    assert result[:result] == 2985.42333984375
  end

  test "static examples of uint8" do
    {result, <<45>>} = F1.DataTypes.uint8({%{}, <<13::8, 45::8>>}, :result)
    assert result[:result] == 13

    {result, <<200>>} = F1.DataTypes.uint8({%{}, <<200::8, 200::8>>}, :result)
    assert result[:result] == 200
  end

  test "static examples of uint16" do
    <<a, b>> = <<2000::16>>
    {result, <<200>>} = F1.DataTypes.uint16({%{}, <<b, a, 200::8>>}, :result)
    assert result[:result] == 2000

    <<a, b>> = <<100::16>>
    {result, <<>>} = F1.DataTypes.uint16({%{}, <<b, a>>}, :result)
    assert result[:result] == 100
  end

  test "static examples of uint32" do
    <<a, b, c, d>> = <<200_000::32>>
    {result, <<200>>} = F1.DataTypes.uint32({%{}, <<d, c, b, a, 200::8>>}, :result)
    assert result[:result] == 200_000

    <<a, b, c, d>> = <<35::32>>
    {result, <<>>} = F1.DataTypes.uint32({%{}, <<d, c, b, a>>}, :result)
    assert result[:result] == 35
  end

  test "static examples of uint64" do
    <<a, b, c, d, e, f, g, h>> = <<200_000_000::64>>
    {result, <<200>>} = F1.DataTypes.uint64({%{}, <<h, g, f, e, d, c, b, a, 200::8>>}, :result)
    assert result[:result] == 200_000_000

    <<a, b, c, d, e, f, g, h>> = <<35::64>>
    {result, <<>>} = F1.DataTypes.uint64({%{}, <<h, g, f, e, d, c, b, a>>}, :result)
    assert result[:result] == 35
  end

  test "static examples of int8" do
    {result, <<>>} = F1.DataTypes.int8({%{}, <<1::1, 100::7>>}, :result)
    assert result[:result] == -28

    {result, <<200>>} = F1.DataTypes.int8({%{}, <<50, 200>>}, :result)
    assert result[:result] == 50
  end

  test "static examples of int16" do
    <<a, b>> = <<1::1, 1000::15>>
    {result, <<>>} = F1.DataTypes.int16({%{}, <<b, a>>}, :result)
    assert result[:result] == -31_768

    <<a, b>> = <<50::16>>
    {result, <<200>>} = F1.DataTypes.int16({%{}, <<b, a, 200>>}, :result)
    assert result[:result] == 50
  end

  test "signing for uint and int types" do
    {result, _rest} = F1.DataTypes.uint8({%{}, <<0xFF::8>>}, :result)
    assert result[:result] == 0xFF

    # Two's complement!
    {result, _rest} = F1.DataTypes.int8({%{}, <<0xFF::8>>}, :result)
    assert result[:result] == -1

    <<a, b>> = <<0xFFFF::16>>
    {result, _rest} = F1.DataTypes.uint16({%{}, <<b, a>>}, :result)
    assert result[:result] == 0xFFFF

    # Two's complement!
    <<a, b>> = <<0xFFFF::16>>
    {result, _rest} = F1.DataTypes.int16({%{}, <<b, a>>}, :result)
    assert result[:result] == -1
  end

  def valid_little_float32?(b) do
    <<a, b, c, d>> = b
    <<_sign::integer-size(1), exp::integer-size(8), _mant::integer-size(23)>> = <<d, c, b, a>>
    exp < 0xFF
  end

  # Generator
  def float32_bitstring do
    such_that b <- bitstring(32), when: valid_little_float32?(b)
  end

  property "the correct number of bytes are processed for float32" do
    forall b <- float32_bitstring() do
      {result, rest} = F1.DataTypes.float32({%{}, b}, :result)
      Map.has_key?(result, :result) && rest == <<>>
    end
  end

  property "the correct number of bytes are processed for uint8" do
    forall b <- bitstring(8) do
      {result, rest} = F1.DataTypes.uint8({%{}, b}, :result)
      Map.has_key?(result, :result) && rest == <<>>
    end
  end

  property "the correct number of bytes are processed for uint16" do
    forall b <- bitstring(16) do
      {result, rest} = F1.DataTypes.uint16({%{}, b}, :result)
      Map.has_key?(result, :result) && rest == <<>>
    end
  end

  property "the correct number of bytes are processed for uint32" do
    forall b <- bitstring(32) do
      {result, rest} = F1.DataTypes.uint32({%{}, b}, :result)
      Map.has_key?(result, :result) && rest == <<>>
    end
  end

  property "the correct number of bytes are processed for uint64" do
    forall b <- bitstring(64) do
      {result, rest} = F1.DataTypes.uint64({%{}, b}, :result)
      Map.has_key?(result, :result) && rest == <<>>
    end
  end

  property "the correct number of bytes are processed for int8" do
    forall b <- bitstring(8) do
      {result, rest} = F1.DataTypes.int8({%{}, b}, :result)
      Map.has_key?(result, :result) && rest == <<>>
    end
  end

  property "the correct number of bytes are processed for int16" do
    forall b <- bitstring(16) do
      {result, rest} = F1.DataTypes.int16({%{}, b}, :result)
      Map.has_key?(result, :result) && rest == <<>>
    end
  end

  property "parsed float32 values are within acceptable range" do
    forall b <- float32_bitstring() do
      {r, _rest} = F1.DataTypes.float32({%{}, b}, :result)
      r[:result] >= -340_282_346_638_528_859_811_704_183_484_516_925_440 &&
        r[:result] <= 340_282_346_638_528_859_811_704_183_484_516_925_440
    end
  end

  property "parsed uint8 values are within acceptable range" do
    forall b <- bitstring(8) do
      {r, _rest} = F1.DataTypes.uint8({%{}, b}, :result)
      r[:result] >= 0 && r[:result] <= 255
    end
  end

  property "parsed uint16 values are within acceptable range" do
    forall b <- bitstring(16) do
      {r, _rest} = F1.DataTypes.uint16({%{}, b}, :result)
      r[:result] >= 0 && r[:result] <= 65_535
    end
  end

  property "parsed uint32 values are within acceptable range" do
    forall b <- bitstring(32) do
      {r, _rest} = F1.DataTypes.uint32({%{}, b}, :result)
      r[:result] >= 0 && r[:result] <= 4_294_967_295
    end
  end

  property "parsed uint64 values are within acceptable range" do
    forall b <- bitstring(64) do
      {r, _rest} = F1.DataTypes.uint64({%{}, b}, :result)
      r[:result] >= 0 && r[:result] <= 18_446_744_073_709_551_615
    end
  end

  property "parsed int8 values are within acceptable range" do
    forall b <- bitstring(8) do
      {r, _rest} = F1.DataTypes.int8({%{}, b}, :result)
      r[:result] >= -128 && r[:result] <= 127
    end
  end

  property "parsed int16 values are within acceptable range" do
    forall b <- bitstring(16) do
      {r, _rest} = F1.DataTypes.int16({%{}, b}, :result)
      r[:result] >= -32_768 && r[:result] <= 32_767
    end
  end

  test "static example of float32 tuple" do
    <<a, b, c, d>> = <<0::1, 124::8, 2_097_152::23>>
    <<e, f, g, h>> = <<0::1, 138::8, 3_839_686::23>>
    {result, <<1, 2, 3>>} = F1.DataTypes.float32(
      {%{}, <<d,c,b,a, h,g,f,e, 1, 2, 3>>},
      :result,
      2
    )
    assert result[:result] == {0.15625, 2985.42333984375}
  end

  test "static example of uint8 tuple" do
    {result, <<33>>} =
      F1.DataTypes.uint8({%{}, <<13::8, 45::8, 33::8>>}, :result, 2)
    assert result[:result] == {13, 45}
  end

  test "static example of uint16 tuple" do
    <<a, b>> = <<2000::16>>
    <<c, d>> = <<100::16>>
    {result, <<200>>} = F1.DataTypes.uint16({%{}, <<b,a, d,c, 200::8>>}, :result, 2)
    assert result[:result] == {2000, 100}
  end

  test "static example of uint32 tuple" do
    <<a, b, c, d>> = <<200_000::32>>
    <<e, f, g, h>> = <<35::32>>
    {result, <<200>>} =
      F1.DataTypes.uint32({%{}, <<d,c,b,a, h,g,f,e, 200::8>>}, :result, 2)
    assert result[:result] == {200_000, 35}
  end

  test "static examples of uint64 tuple" do
    <<a, b, c, d, e, f, g, h>> = <<200_000_000::64>>
    <<i, j, k, l, m, n, o, p>> = <<35::64>>
    {result, <<200>>} = F1.DataTypes.uint64(
      {%{}, <<h,g,f,e,d,c,b,a, p,o,n,m,l,k,j,i, 200::8>>},
      :result,
      2
    )
    assert result[:result] == {200_000_000, 35}
  end

  test "static examples of int8 tuple" do
    {result, <<200>>} =
      F1.DataTypes.int8({%{}, <<1::1, 100::7, 50, 200>>}, :result, 2)
    assert result[:result] == {-28, 50}
  end

  test "static examples of int16 tuple" do
    <<a, b>> = <<1::1, 1000::15>>
    <<c, d>> = <<50::16>>
    {result, <<200>>} =
      F1.DataTypes.int16({%{}, <<b,a, d,c, 200::16>>}, :result, 2)
    assert result[:result] == {-31_768, 50}
  end
end
