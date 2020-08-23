defmodule DataTypesTest do
  use ExUnit.Case

  # https://www.h-schmidt.net/FloatConverter/IEEE754.html
  test "static examples of float32" do
    <<a,b,c,d>> = <<0::1, 124::8, 2097152::23>>
    {result, <<1,2,3>>} = F1.DataTypes.float32({%{}, <<d,c,b,a,1,2,3>>}, :result)
    assert result[:result] == 0.15625

    <<a,b,c,d>> = <<1::1, 124::8, 2097152::23>>
    {result, <<21>>} = F1.DataTypes.float32({%{}, <<d,c,b,a,21>>}, :result)
    assert result[:result] == -0.15625

    <<a,b,c,d>> = <<0::1, 138::8, 3839686::23>>
    {result, <<>>} = F1.DataTypes.float32({%{}, <<d,c,b,a>>}, :result)
    assert result[:result] == 2985.42333984375
  end

  test "static examples of uint8" do
    {result, <<45>>} = F1.DataTypes.uint8({%{}, <<13::8, 45::8>>}, :result)
    assert result[:result] == 13

    {result, <<200>>} = F1.DataTypes.uint8({%{}, <<200::8, 200::8>>}, :result)
    assert result[:result] == 200
  end

  test "static examples of uint16" do
    <<a,b>> = <<2000::16>>
    {result, <<200>>} = F1.DataTypes.uint16({%{}, <<b,a, 200::8>>}, :result)
    assert result[:result] == 2000

    <<a,b>> = <<100::16>>
    {result, <<>>} = F1.DataTypes.uint16({%{}, <<b,a>>}, :result)
    assert result[:result] == 100
  end

  test "static examples of uint32" do
    <<a,b,c,d>> = <<200000::32>>
    {result, <<200>>} = F1.DataTypes.uint32({%{}, <<d,c,b,a, 200::8>>}, :result)
    assert result[:result] == 200000

    <<a,b,c,d>> = <<35::32>>
    {result, <<>>} = F1.DataTypes.uint32({%{}, <<d,c,b,a>>}, :result)
    assert result[:result] == 35
  end

  test "static examples of uint64" do
    <<a,b,c,d,e,f,g,h>> = <<200000000::64>>
    {result, <<200>>} = F1.DataTypes.uint64({%{}, <<h,g,f,e,d,c,b,a, 200::8>>}, :result)
    assert result[:result] == 200000000

    <<a,b,c,d,e,f,g,h>> = <<35::64>>
    {result, <<>>} = F1.DataTypes.uint64({%{}, <<h,g,f,e,d,c,b,a>>}, :result)
    assert result[:result] == 35
  end

  test "static examples of int8" do
    {result, <<>>} = F1.DataTypes.int8({%{}, <<1::1, 100::7>>}, :result)
    assert result[:result] == -28

    {result, <<200>>} = F1.DataTypes.int8({%{}, <<50, 200>>}, :result)
    assert result[:result] == 50
  end

  test "static examples of int16" do
    <<a,b>> = <<1::1, 1000::15>>
    {result, <<>>} = F1.DataTypes.int16({%{}, <<b,a>>}, :result)
    assert result[:result] == -31768

    <<a,b>> = <<50::16>>
    {result, <<200>>} = F1.DataTypes.int16({%{}, <<b,a, 200>>}, :result)
    assert result[:result] == 50
  end

  test "signing for uint and int types" do
    {result, _rest} = F1.DataTypes.uint8({%{}, <<0xFF::8>>}, :result)
    assert result[:result] == 0xFF

    # Two's complement!
    {result, _rest} = F1.DataTypes.int8({%{}, <<0xFF::8>>}, :result)
    assert result[:result] == -1

    <<a,b>> = <<0xFFFF::16>>
    {result, _rest} = F1.DataTypes.uint16({%{}, <<b,a>>}, :result)
    assert result[:result] == 0xFFFF

    # Two's complement!
    <<a,b>> = <<0xFFFF::16>>
    {result, _rest} = F1.DataTypes.int16({%{}, <<b,a>>}, :result)
    assert result[:result] == -1
  end
end
