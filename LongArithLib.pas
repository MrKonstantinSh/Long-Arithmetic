{*******************************************************}
{                                                       }
{    Delphi Long Arithmetic For RSA                     }
{    Encryption Component Library                       }
{                                                       }
{    Copyright (c) 2019 CryptoProsper                   }
{    Created by Konstantin Shulga                       }
{    Date created 17/03/2019                            }
{    Latest update date 30/04/2019                      }
{                                                       }
{*******************************************************}

unit LongArithLib;

interface
  uses
    SysUtils;

  const
    MaxLongNumLen = 10000;    // Maximum array dimension
    Base = 10000;             // "Number System"
    NumOfDigits = 4;          // Number of digits in one cell

    FLNumGreaterSLNum = 1;    // Indicates that the first number
                              //   is greater than the second
    FLNumLessSLNum = -1;      // Indicates that the first number
                              //   is less than the second
    FLNumEqualSLNum = 0;      // Indicates that the first number
                              //   is equal to the second

    Quotient = 'Quotient';    // Indicates that you need to get
                              //   the whole part of the division
    Remainder = 'Remainder';  // Indicates that you need to get
                              //   the remainder of the division

  type
    { TNumericPartLongNum is an array storing the numeric part
      of the "long number". The number is stored in 10,000
      "number systems" (Base). One digit of the number holds
      a maximum of 4 digits (NumOfDigits). In the zero element
      of the array is stored the length of the "long number" }

    TNumericPartLongNum = array[0..MaxLongNumLen] of Word;

    { TLongNum is a record that stores a "long number".
      The first field of the record is the
      "long number" sign (Sign). The second field
      of the record is the numeric part
      of the "long number" (LongNum) }

    TLongNum = record
                 Sign : ShortInt;
                 NumericPLN : TNumericPartLongNum;
               end;

  { Converts a "long number" from a string to an array of numbers
    with Base(10.000) number system. Numbers are placed
    in reverse order (from low-order to high-order) }

  function ConvertStrToLongNum(LongNum: String): TLongNum;

  { Converts a "long number" from an array of numbers to a string }

  function ConvertLongNumToStr(LongNum: TLongNum): String;

  { Returns the largest length of two "long numbers"
    without sign }

  function GetMaxLenOfLongNum(const FirstLongNum,
    SecLongNum: TLongNum): Word;

  { Compares the modular parts of two "long numbers".
    If the first number is greater than the second,
    then returns FLNumGreaterSLNum.
    If the first long number is less than the second,
    then it returns FLNumLessSLNum.
    If the first long number is equal to the second,
    then returns FLNumEqualSLNum }

  function CompareModulesLongNums(FirstLongNum,
    SecLongNum: String): ShortInt;

  { Compares two "long numbers" with the sign.
    If the first number is greater than the second,
    then returns FLNumGreaterSLNum.
    If the first long number is less than the second,
    then it returns FLNumLessSLNum.
    If the first long number is equal to the second,
    then returns FLNumEqualSLNum }

  function CompareLongNums(FirstLongNum,
    SecLongNum: String): ShortInt;

  { Adds to the first "long number" the second,
    taking into account the sign
    and the discharge overflow }

  function AddLongNums(FirstLongNum,
    SecLongNum: String): String;

  { Subtracts from the "first long number" the second,
    taking into account the sign }

  function SubLongNums(FirstLongNum,
    SecLongNum: String): String;

  { Multiplies the first "long number" by the second,
    taking into account the sign
    and overflow of the discharge }

  function MultLongNums(const FirstLongNum,
    SecLongNum: String): String;

  { Calculates the integer part of dividing
    the "long number" into a "short" one,
    taking into account the sign }

   function GetIntPartOfDivLNumBySNum(const LongNum: String;
    ShortNum: LongInt): String;

  { Calculates the remainder of dividing
    a "long number" into a "short" one,
    taking into account the sign }

  function GetRemOfDivLNumBySNum(const LongNum: String;
    const ShortNum: LongInt): String;

  { Finds the integer part and remainder of the division
    of two "long numbers" using a binary search,
    taking into account the sign. ReturnParam indicates
    that it is necessary to return:
    the integer part of the division (Quotient)
    or the remainder (Remainder) }

  function GetQuotOrResBinSearch(FirstLongNum,
    SecLongNum, ReturnParam: String): String;

  { Divides the first "long number" by the second "long number",
    taking into account the sign. ReturnParam indicates
    that it is necessary to return:
    the integer part of the division (Quotient)
    or the remainder (Remainder) }

  function DivideLongNumByLongNum(FirstLongNum,
    SecLongNum, ReturnParam: String): String;

  { Raises the "long number" to the power,
    taking into account the sign using multiplication.
    "Power" can not be negative }

  function RaiseLNumToPower(const Number: String;
    const Power: Byte): String;

  { Converts a "long number" from a decimal number system
    to a binary one by dividing the number by two.
    "Number" can not be negative }

  function ConvertDecToBin(Number: String): String;

  { Builds a number modulo using the fast exponentiation algorithm }

   function PowerNumModulo(const Number, Power, Module: String): String;

  { Gets the multiplicative inverse of the value Number modulo }

  function GetMultInverseMod(const Number, Module: String): String;

implementation
  function ConvertStrToLongNum;
  var
    NewItemPos, ErrorCode : Integer;
    TmpStr : String;
    I : Word;
    // NewItemPos - pointer to the first digit of the new number
  begin
    if LongNum[1] = '-' then
    begin
      Result.Sign := -1;
      Delete(LongNum, 1, 1);
    end
    else
      Result.Sign := 1;

    FillChar(Result.NumericPLN, SizeOf(Result.NumericPLN), 0);
    I := 0;
    NewItemPos := Length(LongNum) - NumOfDigits + 1;

    { While the pointer to the beginning of the new number
      is not negative: copy the NumOfDigits characters
      from the string LongNum and convert the copied string
      into a number }

    while NewItemPos > 0 do
    begin
      Inc(I);
      TmpStr := Copy(LongNum, NewItemPos, NumOfDigits);
      Val(TmpStr, Result.NumericPLN[I], ErrorCode);
      Dec(NewItemPos, NumOfDigits);
    end;

    { If there are senior digits of the number
      (the number of digits is less than 4),
      then copy the remaining digits
      and convert them to the number }

    if NewItemPos + NumOfDigits > 1 then
    begin
      Inc(I);
      TmpStr := Copy(LongNum, 1, NewItemPos + NumOfDigits - 1);
      Val(TmpStr, Result.NumericPLN[I], ErrorCode);
    end;
    Result.NumericPLN[0] := I;
  end;

  function ConvertLongNumToStr;
  var
    I : Word;
  begin
    Result := '';
    if LongNum.Sign = -1 then
      Result := Result + '-';

    for I := LongNum.NumericPLN[0] downto 1 do
    begin
      if I <> LongNum.NumericPLN[0] then
      begin
        if LongNum.NumericPLN[I] < 10 then
          Result := Result + '000' + IntToStr(LongNum.NumericPLN[I])
        else if (LongNum. NumericPLN[I] >= 10) and
          (LongNum.NumericPLN[I] < 100) then

          Result := Result + '00' + IntToStr(LongNum.NumericPLN[I])
        else if (LongNum.NumericPLN[I] >= 100) and
          (LongNum.NumericPLN[I] < 1000) then

          Result := Result + '0' + IntToStr(LongNum.NumericPLN[I])
        else
          Result := Result + IntToStr(LongNum.NumericPLN[I]);
      end
      else
        Result := Result + IntToStr(LongNum.NumericPLN[I]);
    end;
  end;

  function GetMaxLenOfLongNum;
  begin
    if FirstLongNum.NumericPLN[0] > SecLongNum.NumericPLN[0] then
      Result := FirstLongNum.NumericPLN[0]
    else
      Result := SecLongNum.NumericPLN[0];
  end;

  function CompareModulesLongNums;
  var
    Len : Word;
    FLNum, SLNum : TLongNum;
  begin
    FLNum := ConvertStrToLongNum(FirstLongNum);
    SLNum := ConvertStrToLongNum(SecLongNum);
    Len := GetMaxLenOfLongNum(FLNum, SLNum);

    while (Len > 0) and
      (FLNum.NumericPLN[Len] = SLNum.NumericPLN[Len]) do
      Dec(Len);
    if Len = 0 then
      Result := FLNumEqualSLNum
    else if FLNum.NumericPLN[Len] > SLNum.NumericPLN[Len] then
      Result := FLNumGreaterSLNum
    else
      Result := FLNumLessSLNum;
  end;

  function CompareLongNums;
  begin
    if (FirstLongNum[1] = '-') and (SecLongNum[1] <> '-') then
      Result := FLNumLessSLNum
    else if (FirstLongNum[1] <> '-') and (SecLongNum[1] = '-') then
      Result := FLNumGreaterSLNum
    else if (FirstLongNum[1] = '-') and (SecLongNum[1] = '-') then
    begin
      Delete(FirstLongNum, 1, 1);
      Delete(SecLongNum, 1, 1);
      Result := -1 * CompareModulesLongNums(FirstLongNum, SecLongNum);
    end
    else
      Result := CompareModulesLongNums(FirstLongNum, SecLongNum);
  end;

  function AddLongNums;
  var
    Len, Carry, I : Word;
    FLNum, SLNum, ResLNum : TLongNum;
  begin
    FLNum := ConvertStrToLongNum(FirstLongNum);
    SLNum := ConvertStrToLongNum(SecLongNum);
    Len := GetMaxLenOfLongNum(FLNum, SLNum);
    Carry := 0;

    { The addition of two "long numbers" with the sign.
      At discharge overflow, transfer to
      the next discharge is made }

    if (FLNum.Sign = -1) and (SLNum.Sign = 1) then
    begin
      Delete(FirstLongNum, 1, 1);
      Result := SubLongNums(SecLongNum, FirstLongNum);
    end
    else if (FLNum.Sign = 1) and (SLNum.Sign = -1) then
    begin
      Delete(SecLongNum, 1, 1);
      Result := SubLongNums(FirstLongNum, SecLongNum);
    end
    else
    begin
      if (FLNum.Sign = -1) and (SLNum.Sign = -1) then
        ResLNum.Sign := -1
      else
        ResLNum.Sign := 1;
      for I := 1 to Len do
      begin
        Carry := Carry + FLNum.NumericPLN[I] + SLNum.NumericPLN[I];
        ResLNum.NumericPLN[I] := Carry mod Base;
        Carry := Carry div Base;
      end;
      if Carry > 0 then
      begin
        Inc(Len);
        ResLNum.NumericPLN[Len] := Carry;
      end;
      ResLNum.NumericPLN[0] := Len;

      Result := ConvertLongNumToStr(ResLNum);
    end;
  end;

  function SubLongNums;
  var
    Len, Tmp, I : Word;
    Carry : Integer;
    FLNum, SLNum, ResLNum : TLongNum;
  begin
    FLNum := ConvertStrToLongNum(FirstLongNum);
    SLNum := ConvertStrToLongNum(SecLongNum);
    Len := GetMaxLenOfLongNum(FLNum, SLNum);
    Carry := 0;

    { Subtracting from the first "long number" of the second,
      taking into account the signs. If, when subtracting
      successive digits of a number, a negative number
      is obtained, then we borrow from the left digit "Base" }

    if (FLNum.Sign = -1) and (SLNum.Sign = -1) then
    begin
      Delete(SecLongNum, 1, 1);
      Result := AddLongNums(FirstLongNum, SecLongNum);
    end
    else if (FLNum.Sign = 1) and (SLNum.Sign = -1) then
    begin
      Delete(SecLongNum, 1, 1);
      Result := AddlongNums(FirstLongNum, SecLongNum);
    end
    else if (FLNum.Sign = -1) and (SLNum.Sign = 1) then
    begin
      Delete(FirstLongNum, 1, 1);
      Result := '-' + AddlongNums(FirstLongNum, SecLongNum);
    end
    else
    begin
      if CompareModulesLongNums(FirstLongNum, SecLongNum) = FLNumLessSLNum then
      begin
        ResLNum.Sign := -1;

        for I := 1 to Len do
        begin
          Tmp := FLNum.NumericPLN[I];
          FLNum.NumericPLN[I] := SLNum.NumericPLN[I];
          SLNum.NumericPLN[I] := Tmp;
        end;
      end
      else
        ResLNum.Sign := 1;

      for I := 1 to Len do
      begin
        Carry := Carry + FLNum.NumericPLN[I] -
          SLNum.NumericPLN[I] + Base;
        ResLNum.NumericPLN[I] := Carry mod Base;
        if Carry < Base then
          Carry := -1
        else
          Carry := 0;
      end;

      while (ResLNum.NumericPLN[Len] = 0) and (Len > 1) do
        Dec(Len);
      ResLNum.NumericPLN[0] := Len;

      Result := ConvertLongNumToStr(ResLNum);
    end;
  end;

  function MultLongNums;
  var
    I, J, K : Word;
    Carry : LongWord;
    FLNum, SLNum, ResLNum : TLongNum;
  begin
    FLNum := ConvertStrToLongNum(FirstLongNum);
    SLNum := ConvertStrToLongNum(SecLongNum);
    FillChar(ResLNum.NumericPLN, SizeOf(ResLNum.NumericPLN), 0);

    { Multiplication of two "long numbers"
      taking into account the sign
      and overflow of the discharge }

    if (FLNum.Sign = -1) and (SLNum.Sign = -1) then
      ResLNum.Sign := 1
    else if (FLNum.Sign = 1) and (SLNum.Sign = 1) then
      ResLNum.Sign := 1
    else
      ResLNum.Sign := -1;

    for I := 1 to FLNum.NumericPLN[0] do
    begin
      for J := 1 to SLNum.NumericPLN[0] do
      begin
        Carry := FLNum.NumericPLN[I] * SLNum.NumericPLN[J];
        K := I + J - 1;
        while Carry > 0 do
        begin
          Carry := Carry + ResLNum.NumericPLN[K];
          ResLNum.NumericPLN[K] := Carry mod Base;
          Carry := Carry div Base;
          if K > ResLNum.NumericPLN[0] then
            ResLNum.NumericPLN[0] := K;
          Inc(K);
        end;
      end;
    end;

    Result := ConvertLongNumToStr(ResLNum);
  end;

  function GetIntPartOfDivLNumBySNum;
  var
    ResLen, I, K : Word;
    LNum, ResLNum : TLongNum;
    TmpNum : Int64;
    IsContinue : Boolean;
  begin
    FillChar(ResLNum.NumericPLN, SizeOf(ResLNum.NumericPLN), 0);
    LNum := ConvertStrToLongNum(LongNum);
    IsContinue := False;
    TmpNum := 0;
    ResLen := 0;
    K := 0;

    { Calculate the integer part of dividing the "long number"
      into a short one, taking into account the sign }

    if (LNum.Sign = -1) and (ShortNum < 0) then
      ResLNum.Sign := 1
    else if (LNum.Sign = -1) and (ShortNum > 0) then
      ResLNum.Sign := -1
    else if (ShortNum < 0) and (LNum.Sign = 1) then
      ResLNum.Sign := -1
    else if CompareModulesLongNums(LongNum,
      IntToStr(ShortNum)) = FLNumLessSLNum then
      ResLNum.Sign := 1;

    for I := LNum.NumericPLN[0] downto 1 do
    begin
      TmpNum := TmpNum * Base + LNum.NumericPLN[I];
      if (TmpNum < Abs(ShortNum)) and (K = 0) and (I > 1) then
        IsContinue := True;
      if not IsContinue then
      begin
        K := 1;
        Inc(ResLen);
        ResLNum.NumericPLN[I] := TmpNum div Abs(ShortNum);
        TmpNum := TmpNum mod Abs(ShortNum);
      end;
      IsContinue := False;
    end;
    ResLNum.NumericPLN[0] := ResLen;

    Result := ConvertLongNumToStr(ResLNum);
  end;

  function GetRemOfDivLNumBySNum;
  var
    I : Word;
    LNum : TLongNum;
  begin
    if CompareModulesLongNums(LongNum, IntToStr(ShortNum)) = -1 then
      Result := LongNum
    else
    begin
      Result := '0';
      LNum := ConvertStrToLongNum(LongNum);

      for I := LNum.NumericPLN[0] downto 1 do
        Result := IntToStr((StrToInt(Result) *
          Base + LNum.NumericPLN[I]) mod ShortNum);
    end;
  end;

  function GetQuotOrResBinSearch;
  var
    LeftBorder, RightBorder, CentralEl, EstimatedQuot : String;
    IsFindQuotient : Boolean;
  begin
    IsFindQuotient := False;
    Result := '';
    if CompareModulesLongNums(FirstLongNum, SecLongNum) = FLNumLessSLNum then
    begin
      if ReturnParam = Quotient then
        Result := '0'
      else if ReturnParam = Remainder then
        Result := FirstLongNum;
    end
    else
    begin
      if (FirstLongNum[1] = '-') and (SecLongNum[1] <> '-')
        and (ReturnParam = Quotient) then
      begin
        Delete(FirstLongNum, 1, 1);
        Result := '-';
      end
      else if (FirstLongNum[1] <> '-') and (SecLongNum[1] = '-')
        and (ReturnParam = Quotient) then
      begin
        Delete(SecLongNum, 1, 1);
        Result := '-';
      end
      else if (FirstLongNum[1] = '-') and (SecLongNum[1] = '-')
        and (ReturnParam = Quotient) then
      begin
        Delete(FirstLongNum, 1, 1);
        Delete(SecLongNum, 1, 1);
        Result := '';
      end
      else if (FirstLongNum[1] = '-') and (SecLongNum[1] <> '-')
        and (ReturnParam = Remainder) then
      begin
        Delete(FirstLongNum, 1, 1);
        Result := '-';
      end
      else if (FirstLongNum[1] <> '-') and (SecLongNum[1] = '-')
        and (ReturnParam = Remainder) then
      begin
        Delete(SecLongNum, 1, 1);
        Result := '';
      end
      else if (FirstLongNum[1] = '-') and (SecLongNum[1] = '-')
        and (ReturnParam = Remainder) then
      begin
        Delete(FirstLongNum, 1, 1);
        Delete(SecLongNum, 1, 1);
        Result := '-';
      end;

      LeftBorder := '1';
      RightBorder := FirstLongNum;

      { Binary search for the required private }

      while (CompareModulesLongNums(SubLongNums(RightBorder, '1'),
        LeftBorder) = 1) and not IsFindQuotient do
      begin
        CentralEl := GetIntPartOfDivLNumBySNum(AddLongNums(LeftBorder,
          RightBorder), 2);
        EstimatedQuot := MultLongNums(CentralEl, SecLongNum);
        case CompareModulesLongNums(FirstLongNum, EstimatedQuot) of
          FLNumGreaterSLNum : LeftBorder := CentralEl;
          FLNumEqualSLNum : IsFindQuotient := True;
          FLNumLessSLNum : RightBorder := CentralEl;
        end;
      end;

      if ReturnParam = Quotient then
        Result := Result + GetIntPartOfDivLNumBySNum(AddLongNums(RightBorder,
          LeftBorder), 2)
      else if ReturnParam = Remainder then
        Result := Result + SubLongNums(FirstLongNum,
          MultLongNums(GetIntPartOfDivLNumBySNum(AddLongNums(RightBorder,
          LeftBorder), 2), SecLongNum))
      else
        Result := 'Dividing error!';
    end;
  end;

  function DivideLongNumByLongNum;
  begin
    if (SecLongNum = '1') and (ReturnParam = Quotient) then
      Result := FirstLongNum
    else if (SecLongNum = '-1') and (ReturnParam = Quotient) then
      Result := '-' + FirstLongNum
    else if (SecLongNum = '1') or (SecLongNum = '-1')
      and (ReturnParam = Remainder) then
      Result := '0'
    else if SecLongNum = '0' then
      Result := 'Division error by zero!'
    else
      Result := GetQuotOrResBinSearch(FirstLongNum,
        SecLongNum, ReturnParam);
  end;

  function RaiseLNumToPower;
  var
    I : LongWord;
  begin
    Result := '1';
    I := 1;

    if (Power = 0) and (Number[1] <> '-') then
      Result := '1'
    else if (Power = 0) and (Number[1] = '-') then
      Result := '-1'
    else if Power = 1 then
      Result := Number
    else
    begin
      while I <= Power do
      begin
        Result := MultLongNums(Result, Number);
        Inc(I);
      end;
    end;
  end;

  function ConvertDecToBin;
  var
    I : Integer;
    TmpStr: String;
  begin
    if Number[1] = '-' then
      Result := 'The number can not be negative!'
    else
    begin
      TmpStr := '';

      { Converts a number from the decimal number system
        to the binary number system by dividing it by two }

      while (Number <> '0') and (Number <> '1') do
      begin
        TmpStr := TmpStr + GetRemOfDivLNumBySNum(Number, 2);
        Number := GetIntPartOfDivLNumBySNum(Number, 2);
      end;
      TmpStr := TmpStr + Number;
      SetLength(Result, Length(TmpStr));
      for I := 1 to Length(TmpStr) do
        Result[I] := TmpStr[Length(TmpStr)-I+1];
    end;
  end;

  function PowerNumModulo;
  var
    PowerInBinRep : String;
    I : Word;
  begin
    PowerInBinRep := ConvertDecToBin(Power);
    Result := '1';
    for I := 1 to Length(PowerInBinRep) - 1 do
    begin
      Result := DivideLongNumByLongNum(RaiseLNumToPower(MultLongNums(Result,
        RaiseLNumToPower(Number, StrToInt(PowerInBinRep[I]))),
        2), Module, Remainder);

    end;
      Result := DivideLongNumByLongNum(MultLongNums(Result,
        RaiseLNumToPower(Number,
        StrToInt(PowerInBinRep[Length(PowerInBinRep)]))),
        Module, Remainder);
  end;

  function GetMultInverseMod;
  var
    T, R, NewT, NewR, Q, Tmp : String;
    IsInvertable : Boolean;
  begin
    T := '0';
    R := Module;
    NewT := '1';
    NewR := Number;
    IsInvertable := True;

    while NewR <> '0' do
    begin
      Q := DivideLongNumByLongNum(R, NewR, Quotient);

      Tmp := SubLongNums(T, MultLongNums(Q, NewT));
      T := NewT;
      NewT := Tmp;

      Tmp := SubLongNums(R, MultLongNums(Q, NewR));
      R := NewR;
      NewR := Tmp;
    end;
    if CompareModulesLongNums(R, '1') = FLNumGreaterSLNum then
    begin
      Result := 'Number is not invertable!';
      IsInvertable := False
    end;
    if IsInvertable then
    begin
      if CompareLongNums(T, '0') = FLNumLessSLNum then
        T := AddLongNums(T, Module);
      Result := T;
    end;
  end;
end.
