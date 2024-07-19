--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local FlatIdent_95CAC = 0;
			local a;
			while true do
				if (FlatIdent_95CAC == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local b = Rep(a, repeatNext);
						repeatNext = nil;
						return b;
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local FlatIdent_76979 = 0;
			local Plc;
			while true do
				if (FlatIdent_76979 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_69270 = 0;
				while true do
					if (FlatIdent_69270 == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_12703 = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_12703 == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_12703 = 1;
				end
				if (FlatIdent_12703 == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					Inst[3] = gBits32() - (2 ^ 16);
					Inst[4] = gBits16();
				end
				if (gBit(Mask, 1, 1) == 1) then
					Inst[2] = Consts[Inst[2]];
				end
				if (gBit(Mask, 2, 2) == 1) then
					Inst[3] = Consts[Inst[3]];
				end
				if (gBit(Mask, 3, 3) == 1) then
					Inst[4] = Consts[Inst[4]];
				end
				Instrs[Idx] = Inst;
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_475BC = 0;
				while true do
					if (FlatIdent_475BC == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_475BC = 1;
					end
					if (FlatIdent_475BC == 1) then
						if (Enum <= 42) then
							if (Enum <= 20) then
								if (Enum <= 9) then
									if (Enum <= 4) then
										if (Enum <= 1) then
											if (Enum == 0) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											else
												Stk[Inst[2]] = Env[Inst[3]];
											end
										elseif (Enum <= 2) then
											local A = Inst[2];
											Stk[A](Stk[A + 1]);
										elseif (Enum > 3) then
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										else
											local FlatIdent_43862 = 0;
											local A;
											while true do
												if (0 == FlatIdent_43862) then
													A = Inst[2];
													do
														return Unpack(Stk, A, A + Inst[3]);
													end
													break;
												end
											end
										end
									elseif (Enum <= 6) then
										if (Enum == 5) then
											do
												return;
											end
										else
											local A = Inst[2];
											local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											local Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
										end
									elseif (Enum <= 7) then
										Stk[Inst[2]] = not Stk[Inst[3]];
									elseif (Enum > 8) then
										local B = Stk[Inst[4]];
										if not B then
											VIP = VIP + 1;
										else
											Stk[Inst[2]] = B;
											VIP = Inst[3];
										end
									else
										local FlatIdent_8F047 = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (7 == FlatIdent_8F047) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8F047 = 8;
											end
											if (3 == FlatIdent_8F047) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_8F047 = 4;
											end
											if (2 == FlatIdent_8F047) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_8F047 = 3;
											end
											if (FlatIdent_8F047 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8F047 = 6;
											end
											if (FlatIdent_8F047 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8F047 = 2;
											end
											if (FlatIdent_8F047 == 6) then
												A = Inst[2];
												Stk[A] = Stk[A]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_8F047 = 7;
											end
											if (FlatIdent_8F047 == 8) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_8F047 == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_8F047 = 1;
											end
											if (FlatIdent_8F047 == 4) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_8F047 = 5;
											end
										end
									end
								elseif (Enum <= 14) then
									if (Enum <= 11) then
										if (Enum == 10) then
											local FlatIdent_99389 = 0;
											local A;
											while true do
												if (FlatIdent_99389 == 0) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
											end
										else
											Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
										end
									elseif (Enum <= 12) then
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Enum > 13) then
										Stk[Inst[2]]();
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 17) then
									if (Enum <= 15) then
										local A = Inst[2];
										local Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										local Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									elseif (Enum == 16) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									else
										local K;
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										B = Inst[3];
										K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 18) then
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 19) then
									local A = Inst[2];
									do
										return Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 31) then
								if (Enum <= 25) then
									if (Enum <= 22) then
										if (Enum == 21) then
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
										end
									elseif (Enum <= 23) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum > 24) then
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										do
											return Unpack(Stk, A, Top);
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									else
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									end
								elseif (Enum <= 28) then
									if (Enum <= 26) then
										local FlatIdent_8CEDF = 0;
										local K;
										local B;
										while true do
											if (FlatIdent_8CEDF == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_8CEDF = 3;
											end
											if (FlatIdent_8CEDF == 0) then
												K = nil;
												B = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_8CEDF = 1;
											end
											if (FlatIdent_8CEDF == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_8CEDF = 2;
											end
											if (FlatIdent_8CEDF == 4) then
												K = Stk[B];
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												FlatIdent_8CEDF = 5;
											end
											if (FlatIdent_8CEDF == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												B = Inst[3];
												FlatIdent_8CEDF = 4;
											end
											if (FlatIdent_8CEDF == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if (Stk[Inst[2]] == Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
										end
									elseif (Enum == 27) then
										local A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									else
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 29) then
									VIP = Inst[3];
								elseif (Enum > 30) then
									local FlatIdent_759F1 = 0;
									local A;
									while true do
										if (0 == FlatIdent_759F1) then
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
									end
								else
									Stk[Inst[2]] = Inst[3] ^ Stk[Inst[4]];
								end
							elseif (Enum <= 36) then
								if (Enum <= 33) then
									if (Enum == 32) then
										if (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 34) then
									local B = Inst[3];
									local K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
								elseif (Enum > 35) then
									local A;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_324DE = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_324DE == 2) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_324DE = 3;
										end
										if (FlatIdent_324DE == 5) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_324DE = 6;
										end
										if (7 == FlatIdent_324DE) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_324DE = 8;
										end
										if (FlatIdent_324DE == 6) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_324DE = 7;
										end
										if (FlatIdent_324DE == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_324DE = 1;
										end
										if (FlatIdent_324DE == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_324DE = 2;
										end
										if (8 == FlatIdent_324DE) then
											if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_324DE == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_324DE = 4;
										end
										if (FlatIdent_324DE == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_324DE = 5;
										end
									end
								end
							elseif (Enum <= 39) then
								if (Enum <= 37) then
									Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
								elseif (Enum > 38) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
								else
									local FlatIdent_68E92 = 0;
									local Edx;
									local Results;
									local B;
									local A;
									while true do
										if (FlatIdent_68E92 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_68E92 = 3;
										end
										if (FlatIdent_68E92 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_466B2 = 0;
												while true do
													if (FlatIdent_466B2 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_68E92 = 5;
										end
										if (FlatIdent_68E92 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_68E92 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_68E92 = 2;
										end
										if (FlatIdent_68E92 == 0) then
											Edx = nil;
											Results = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_68E92 = 1;
										end
										if (FlatIdent_68E92 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_68E92 = 4;
										end
									end
								end
							elseif (Enum <= 40) then
								Stk[Inst[2]] = Inst[3];
							elseif (Enum == 41) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 63) then
							if (Enum <= 52) then
								if (Enum <= 47) then
									if (Enum <= 44) then
										if (Enum > 43) then
											local FlatIdent_1A54 = 0;
											local B;
											local A;
											while true do
												if (3 == FlatIdent_1A54) then
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1A54 = 4;
												end
												if (FlatIdent_1A54 == 5) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_1A54 = 6;
												end
												if (FlatIdent_1A54 == 7) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_1A54 = 8;
												end
												if (FlatIdent_1A54 == 4) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1A54 = 5;
												end
												if (FlatIdent_1A54 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													FlatIdent_1A54 = 1;
												end
												if (FlatIdent_1A54 == 6) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1A54 = 7;
												end
												if (FlatIdent_1A54 == 8) then
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_1A54 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_1A54 = 3;
												end
												if (FlatIdent_1A54 == 1) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_1A54 = 2;
												end
											end
										else
											local A = Inst[2];
											Stk[A] = Stk[A]();
										end
									elseif (Enum <= 45) then
										Upvalues[Inst[3]] = Stk[Inst[2]];
									elseif (Enum > 46) then
										local A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
									else
										local FlatIdent_691EB = 0;
										local A;
										while true do
											if (FlatIdent_691EB == 4) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_691EB = 5;
											end
											if (FlatIdent_691EB == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_691EB = 3;
											end
											if (FlatIdent_691EB == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_691EB = 1;
											end
											if (FlatIdent_691EB == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_691EB = 7;
											end
											if (FlatIdent_691EB == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_691EB = 2;
											end
											if (FlatIdent_691EB == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_691EB = 4;
											end
											if (FlatIdent_691EB == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_691EB = 6;
											end
											if (FlatIdent_691EB == 7) then
												Stk[Inst[2]] = Inst[3];
												break;
											end
										end
									end
								elseif (Enum <= 49) then
									if (Enum > 48) then
										local FlatIdent_68856 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_68856 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_68856 = 1;
											end
											if (FlatIdent_68856 == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_68856 = 2;
											end
											if (4 == FlatIdent_68856) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_68856 = 5;
											end
											if (FlatIdent_68856 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												break;
											end
											if (FlatIdent_68856 == 6) then
												Inst = Instr[VIP];
												Env[Inst[3]] = Stk[Inst[2]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_68856 = 7;
											end
											if (FlatIdent_68856 == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_68856 = 3;
											end
											if (FlatIdent_68856 == 7) then
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Env[Inst[3]] = Stk[Inst[2]];
												FlatIdent_68856 = 8;
											end
											if (FlatIdent_68856 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_68856 = 6;
											end
											if (FlatIdent_68856 == 3) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_68856 = 4;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 50) then
									local K;
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								elseif (Enum > 51) then
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									local FlatIdent_3F7F4 = 0;
									local A;
									local Cls;
									while true do
										if (0 == FlatIdent_3F7F4) then
											A = Inst[2];
											Cls = {};
											FlatIdent_3F7F4 = 1;
										end
										if (FlatIdent_3F7F4 == 1) then
											for Idx = 1, #Lupvals do
												local List = Lupvals[Idx];
												for Idz = 0, #List do
													local FlatIdent_8638E = 0;
													local Upv;
													local NStk;
													local DIP;
													while true do
														if (FlatIdent_8638E == 1) then
															DIP = Upv[2];
															if ((NStk == Stk) and (DIP >= A)) then
																local FlatIdent_957A4 = 0;
																while true do
																	if (FlatIdent_957A4 == 0) then
																		Cls[DIP] = NStk[DIP];
																		Upv[1] = Cls;
																		break;
																	end
																end
															end
															break;
														end
														if (FlatIdent_8638E == 0) then
															Upv = List[Idz];
															NStk = Upv[1];
															FlatIdent_8638E = 1;
														end
													end
												end
											end
											break;
										end
									end
								end
							elseif (Enum <= 57) then
								if (Enum <= 54) then
									if (Enum > 53) then
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local K;
										local B;
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										B = Inst[3];
										K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 55) then
									local Results;
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_71EE8 = 0;
										while true do
											if (FlatIdent_71EE8 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								elseif (Enum > 56) then
									if (Inst[2] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_89917 = 0;
									while true do
										if (FlatIdent_89917 == 2) then
											Env[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_89917 = 3;
										end
										if (FlatIdent_89917 == 0) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_89917 = 1;
										end
										if (FlatIdent_89917 == 1) then
											Stk[Inst[2]] = not Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_89917 = 2;
										end
										if (3 == FlatIdent_89917) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_89917 = 4;
										end
										if (FlatIdent_89917 == 4) then
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								end
							elseif (Enum <= 60) then
								if (Enum <= 58) then
									local K;
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 59) then
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								else
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return Stk[Inst[2]];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 61) then
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									local FlatIdent_55D83 = 0;
									while true do
										if (FlatIdent_55D83 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							elseif (Enum > 62) then
								local Results;
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 74) then
							if (Enum <= 68) then
								if (Enum <= 65) then
									if (Enum > 64) then
										Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									else
										local A = Inst[2];
										local C = Inst[4];
										local CB = A + 2;
										local Result = {Stk[A](Stk[A + 1], Stk[CB])};
										for Idx = 1, C do
											Stk[CB + Idx] = Result[Idx];
										end
										local R = Result[1];
										if R then
											Stk[CB] = R;
											VIP = Inst[3];
										else
											VIP = VIP + 1;
										end
									end
								elseif (Enum <= 66) then
									local FlatIdent_8BA1E = 0;
									local K;
									local B;
									local A;
									while true do
										if (FlatIdent_8BA1E == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_8BA1E = 4;
										end
										if (24 == FlatIdent_8BA1E) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
										if (FlatIdent_8BA1E == 14) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8BA1E = 15;
										end
										if (FlatIdent_8BA1E == 5) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8BA1E = 6;
										end
										if (FlatIdent_8BA1E == 21) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											FlatIdent_8BA1E = 22;
										end
										if (FlatIdent_8BA1E == 12) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8BA1E = 13;
										end
										if (6 == FlatIdent_8BA1E) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_8BA1E = 7;
										end
										if (FlatIdent_8BA1E == 15) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8BA1E = 16;
										end
										if (11 == FlatIdent_8BA1E) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8BA1E = 12;
										end
										if (FlatIdent_8BA1E == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BA1E = 5;
										end
										if (FlatIdent_8BA1E == 13) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BA1E = 14;
										end
										if (FlatIdent_8BA1E == 10) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8BA1E = 11;
										end
										if (FlatIdent_8BA1E == 23) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_8BA1E = 24;
										end
										if (FlatIdent_8BA1E == 1) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8BA1E = 2;
										end
										if (FlatIdent_8BA1E == 16) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_8BA1E = 17;
										end
										if (FlatIdent_8BA1E == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BA1E = 9;
										end
										if (FlatIdent_8BA1E == 22) then
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											for Idx = Inst[2], Inst[3] do
												Stk[Idx] = nil;
											end
											FlatIdent_8BA1E = 23;
										end
										if (FlatIdent_8BA1E == 9) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BA1E = 10;
										end
										if (FlatIdent_8BA1E == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8BA1E = 3;
										end
										if (FlatIdent_8BA1E == 20) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8BA1E = 21;
										end
										if (FlatIdent_8BA1E == 18) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BA1E = 19;
										end
										if (FlatIdent_8BA1E == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8BA1E = 8;
										end
										if (FlatIdent_8BA1E == 0) then
											K = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8BA1E = 1;
										end
										if (FlatIdent_8BA1E == 17) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BA1E = 18;
										end
										if (FlatIdent_8BA1E == 19) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8BA1E = 20;
										end
									end
								elseif (Enum == 67) then
									local FlatIdent_11AA1 = 0;
									local NewProto;
									local NewUvals;
									local Indexes;
									while true do
										if (FlatIdent_11AA1 == 2) then
											for Idx = 1, Inst[4] do
												VIP = VIP + 1;
												local Mvm = Instr[VIP];
												if (Mvm[1] == 73) then
													Indexes[Idx - 1] = {Stk,Mvm[3]};
												else
													Indexes[Idx - 1] = {Upvalues,Mvm[3]};
												end
												Lupvals[#Lupvals + 1] = Indexes;
											end
											Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
											break;
										end
										if (FlatIdent_11AA1 == 0) then
											NewProto = Proto[Inst[3]];
											NewUvals = nil;
											FlatIdent_11AA1 = 1;
										end
										if (1 == FlatIdent_11AA1) then
											Indexes = {};
											NewUvals = Setmetatable({}, {__index=function(_, Key)
												local Val = Indexes[Key];
												return Val[1][Val[2]];
											end,__newindex=function(_, Key, Value)
												local Val = Indexes[Key];
												Val[1][Val[2]] = Value;
											end});
											FlatIdent_11AA1 = 2;
										end
									end
								else
									local FlatIdent_7D3C9 = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_7D3C9 == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											FlatIdent_7D3C9 = 1;
										end
										if (FlatIdent_7D3C9 == 1) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7D3C9 = 2;
										end
										if (FlatIdent_7D3C9 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_7D3C9 == 5) then
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7D3C9 = 6;
										end
										if (FlatIdent_7D3C9 == 3) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_7D3C9 = 4;
										end
										if (FlatIdent_7D3C9 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_7D3C9 = 3;
										end
										if (FlatIdent_7D3C9 == 4) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											FlatIdent_7D3C9 = 5;
										end
										if (FlatIdent_7D3C9 == 6) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_7D3C9 = 7;
										end
									end
								end
							elseif (Enum <= 71) then
								if (Enum <= 69) then
									local FlatIdent_523B3 = 0;
									local K;
									local B;
									local A;
									while true do
										if (FlatIdent_523B3 == 6) then
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_523B3 = 7;
										end
										if (FlatIdent_523B3 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_523B3 = 3;
										end
										if (FlatIdent_523B3 == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_523B3 = 5;
										end
										if (FlatIdent_523B3 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_523B3 = 4;
										end
										if (FlatIdent_523B3 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											FlatIdent_523B3 = 6;
										end
										if (8 == FlatIdent_523B3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											break;
										end
										if (FlatIdent_523B3 == 7) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_523B3 = 8;
										end
										if (FlatIdent_523B3 == 0) then
											K = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_523B3 = 1;
										end
										if (FlatIdent_523B3 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_523B3 = 2;
										end
									end
								elseif (Enum == 70) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
								else
									Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
								end
							elseif (Enum <= 72) then
								local FlatIdent_129E6 = 0;
								local A;
								local Results;
								local Edx;
								while true do
									if (0 == FlatIdent_129E6) then
										A = Inst[2];
										Results = {Stk[A](Stk[A + 1])};
										FlatIdent_129E6 = 1;
									end
									if (FlatIdent_129E6 == 1) then
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_91A09 = 0;
											while true do
												if (FlatIdent_91A09 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										break;
									end
								end
							elseif (Enum > 73) then
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 79) then
							if (Enum <= 76) then
								if (Enum == 75) then
									Env[Inst[3]] = Stk[Inst[2]];
								else
									do
										return Stk[Inst[2]];
									end
								end
							elseif (Enum <= 77) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
							elseif (Enum == 78) then
								local FlatIdent_77CC3 = 0;
								local A;
								while true do
									if (FlatIdent_77CC3 == 0) then
										A = Inst[2];
										do
											return Unpack(Stk, A, Top);
										end
										break;
									end
								end
							else
								local FlatIdent_3416F = 0;
								local B;
								local A;
								while true do
									if (2 == FlatIdent_3416F) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_3416F = 3;
									end
									if (FlatIdent_3416F == 9) then
										Stk[A] = B[Inst[4]];
										break;
									end
									if (7 == FlatIdent_3416F) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3416F = 8;
									end
									if (3 == FlatIdent_3416F) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_3416F = 4;
									end
									if (FlatIdent_3416F == 6) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3416F = 7;
									end
									if (FlatIdent_3416F == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_3416F = 2;
									end
									if (FlatIdent_3416F == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_3416F = 1;
									end
									if (FlatIdent_3416F == 8) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_3416F = 9;
									end
									if (FlatIdent_3416F == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_3416F = 6;
									end
									if (FlatIdent_3416F == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_3416F = 5;
									end
								end
							end
						elseif (Enum <= 82) then
							if (Enum <= 80) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 81) then
								local A = Inst[2];
								local B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							else
								Stk[Inst[2]] = {};
							end
						elseif (Enum <= 83) then
							if (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 84) then
							if Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							Stk[Inst[2]] = Inst[3] ~= 0;
						end
						VIP = VIP + 1;
						break;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!1D3O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F626C2O6F6462612O6C2F2D6261636B2D7570732D666F722D6C6962732F6D61696E2F77697A61726403093O004E657757696E646F77030F3O006E692O676572626561746572363738030A3O004E657753656374696F6E2O033O0041544B03053O004D69736373030C3O007472616E73706172656E637902AE47E17A14AEEF3F2O033O004A2O4B2O033O0065737003023O005F4703083O0044697361626C65642O01030A3O0047657453657276696365030A3O0052756E5365727669636503073O00436F726547756903073O00506C6179657273030D3O0043726561746554657874626F7803063O00486974626F78030A3O006765746E692O67657273030C3O00437265617465546F2O676C6503083O0053686F7720657370030D3O00496E76697320426C7565426F7803073O00676574522O6F7403053O00726F756E642O033O00455350003D3O0012083O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O0001000200202O00013O000500122O000300066O000100030002002051000200010007001231000400086O00020004000200202O00030001000700122O000500096O00030005000200122O0004000B3O00122O0004000A6O000400013O00122O0004000C6O00045O00124B0004000D3O0012160004000E3O00302O0004000F001000122O000400023O00202O00040004001100122O000600126O0004000600024O00055O00122O000600023O00202O00060006001300122O000700023O00202O000700070014002051000800020015001228000A00163O000247000B6O001F0008000B0001000247000800013O00124B000800173O002051000800020018001228000A00193O000643000B0002000100022O00493O00054O00493O00064O001F0008000B0001002051000800030018001228000A001A3O000247000B00034O001F0008000B0001000247000800043O00124B0008001B3O000247000800053O00124B0008001C3O00064300080006000100042O00493O00074O00493O00064O00493O00054O00493O00043O00124B0008001D4O00338O00053O00013O00073O00083O00028O0003023O005F4703083O004865616453697A6503043O0067616D65030A3O0047657453657276696365030A3O0052756E53657276696365030D3O0052656E6465725374652O70656403073O00636F2O6E65637401103O001228000100013O002620000100010001000100041D3O00010001001201000200023O00104F000200033O00122O000200043O00202O00020002000500122O000400066O00020004000200202O00020002000700202O00020002000800024700046O001F00020004000100041D3O000F000100041D3O000100012O00053O00013O00013O000A3O0003023O005F4703083O0044697361626C656403043O006E65787403043O0067616D65030A3O004765745365727669636503073O00506C6179657273030A3O00476574506C617965727303043O004E616D65030B3O004C6F63616C506C6179657203053O007063612O6C001D3O0012013O00013O00206O00020006553O001C00013O00041D3O001C00010012013O00033O001226000100043O00202O00010001000500122O000300066O00010003000200202O0001000100074O00010002000200044O001A000100202O000500040008001223000600043O00202O00060006000500122O000800066O00060008000200202O00060006000900202O00060006000800062O000500190001000600041D3O001900010012010005000A3O00064300063O000100012O00493O00044O00020005000200012O003300035O0006403O000C0001000200041D3O000C00012O00053O00013O00013O00123O00028O00026O00F03F03093O0043686172616374657203103O0048756D616E6F6964522O6F7450617274030A3O00427269636B436F6C6F722O033O006E6577030B3O005265612O6C7920626C756503083O004D6174657269616C03043O004E656F6E027O004003043O0053697A6503073O00566563746F723303023O005F4703083O004865616453697A65030C3O005472616E73706172656E6379030C3O007472616E73706172656E6379030A3O0043616E436F2O6C696465012O002E3O0012283O00013O0026203O00100001000200041D3O001000012O002700015O00202E00010001000300202O00010001000400122O000200053O00202O00020002000600122O000300076O00020002000200102O0001000500024O00015O00202O00010001000300202O00010001000400302O00010008000900124O000A3O0026203O00250001000100041D3O002500012O002700015O00200D00010001000300202O00010001000400122O0002000C3O00202O00020002000600122O0003000D3O00202O00030003000E00122O0004000D3O00202O00040004000E00122O0005000D3O00202O00050005000E4O00020005000200102O0001000B00024O00015O00202O00010001000300202O00010001000400122O000200103O00102O0001000F000200124O00023O0026203O00010001000A00041D3O000100012O002700015O00202O00010001000300202O00010001000400304600010011001200041D3O002D000100041D3O000100012O00053O00017O00133O00028O00027O0040030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E03053O007063612O6C026O00F03F03073O00636F6E74656E7403093O00757365726E616D653A03043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503053O000A2049503A03073O00482O747047657403163O00682O7470733A2O2F6170692E69706966792E6F72672F030A3O004A534F4E456E636F646503793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F313236313538363430323337303532333233362F6778446F70345F786B444935517278382D4B313458645662416D4547446477514B635A304F6A45344C6F50315F4C4A2O5F7167626775734D444D44582D63493858735F6D030A3O0047657453657276696365030B3O00482O74705365727669636500403O0012283O00014O0018000100073O0026203O00100001000200041D3O001000012O005200083O00010030460008000300042O0049000500083O001201000800053O00064300093O000100032O00493O00014O00493O00044O00493O00054O00480008000200092O0049000700094O0049000600083O00041D3O003F00010026203O002D0001000600041D3O002D0001001228000800013O002620000800280001000100041D3O002800012O005200093O0001001235000A00083O00122O000B00093O00202O000B000B000A00202O000B000B000B00202O000B000B000C00122O000C000D3O00122O000D00093O00202O000D000D000E00122O000F000F6O000D000F00024O000A000A000D00102O00090007000A4O000300093O00202O0009000200104O000B00036O0009000B00024O000400093O00122O000800063O002620000800130001000600041D3O001300010012283O00023O00041D3O002D000100041D3O001300010026203O00020001000100041D3O00020001001228000800013O000E39000600340001000800041D3O003400010012283O00063O00041D3O00020001002620000800300001000100041D3O00300001001228000100113O00120C000900093O00202O00090009001200122O000B00136O0009000B00024O000200093O00122O000800063O00044O0030000100041D3O000200012O00053O00013O00013O00063O0003073O00726571756573742O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273000C3O0012193O00016O00013O00044O00025O00102O0001000200024O000200013O00102O00010003000200302O0001000400054O000200023O00102O0001000600026O00019O008O00017O000F3O00028O002O0103053O00706169727303043O0067616D6503073O00506C6179657273030A3O00476574506C617965727303043O004E616D65030B3O004C6F63616C506C617965722O033O00455350030B3O004765744368696C6472656E03063O00737472696E672O033O00737562026O0010C003043O005F45535003073O0044657374726F7901373O001228000100014O0018000200023O002620000100020001000100041D3O00020001001228000200013O002620000200050001000100041D3O000500012O002700036O0007000300034O002D00036O002700035O002620000300210001000200041D3O00210001001201000300033O001237000400043O00202O00040004000500202O0004000400064O000400056O00033O000500044O001E000100202O00080007000700123E000900043O00202O00090009000500202O00090009000800202O00090009000700062O0008001E0001000900041D3O001E0001001201000800094O0049000900074O0002000800020001000640000300140001000200041D3O0014000100041D3O00360001001201000300034O001C000400013O00202O00040004000A4O000400056O00033O000500044O003000010012010008000B3O00201700080008000C00202O00090007000700122O000A000D6O0008000A000200262O000800300001000E00041D3O0030000100205100080007000F2O0002000800020001000640000300270001000200041D3O0027000100041D3O0036000100041D3O0005000100041D3O0036000100041D3O000200012O00053O00017O00063O002O033O004A2O4B0100030C3O007472616E73706172656E6379026O00F03F2O0102AE47E17A14AEEF3F010F3O001238000100016O000100013O00122O000100013O00122O000100013O00262O000100090001000200041D3O00090001001228000100043O00124B000100033O00041D3O000E0001001201000100013O0026200001000E0001000500041D3O000E0001001228000100063O00124B000100034O00053O00017O00053O00028O00030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403053O00546F72736F030A3O00552O706572546F72736F01153O001228000100014O0018000200023O000E39000100020001000100041D3O0002000100205100033O0002001228000500034O000A000300050002000609000200120001000300041D3O0012000100205100033O0002001228000500044O000A000300050002000609000200120001000300041D3O0012000100205100033O0002001228000500054O000A0003000500022O0049000200034O004C000200023O00041D3O000200012O00053O00017O00053O00028O00026O00244003043O006D61746803053O00666C2O6F72026O00E03F02153O001228000200014O0018000300033O002620000200020001000100041D3O00020001001228000400013O002620000400050001000100041D3O000500010006090005000A0001000100041D3O000A0001001228000500013O00101E00030002000500123C000500033O00202O0005000500044O00063O000300202O0006000600054O0005000200024O0005000500034O000500023O00044O0005000100041D3O000200012O00053O00017O00023O0003043O007461736B03053O00737061776E010A3O001201000100013O00202O00010001000200064300023O000100052O00498O00278O00273O00014O00273O00024O00273O00034O00020001000200012O00053O00013O00013O003C3O00028O00026O00F03F03093O0043686172616374657203043O004E616D65030B3O004C6F63616C506C61796572030E3O0046696E6446697273744368696C6403043O005F45535003083O00496E7374616E63652O033O006E657703063O00466F6C64657203063O00506172656E7403043O007761697403073O00676574522O6F7403153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F696403053O007061697273030B3O004765744368696C6472656E2O033O0049734103083O004261736550617274026O00104003053O00436F6C6F7203093O005465616D436F6C6F7203073O0041646F726E2O65027O0040026O00084003043O0053697A65030C3O005472616E73706172656E6379026O66EE3F03123O00426F7848616E646C6541646F726E6D656E74030B3O00416C776179734F6E546F702O0103063O005A496E646578026O00244003043O0048656164030C3O0042692O6C626F61726447756903093O00546578744C6162656C03053O005544696D32026O005940025O00C06240030B3O0053747564734F2O6673657403073O00566563746F723303163O004261636B67726F756E645472616E73706172656E637903083O00506F736974696F6E026O0049C003043O00466F6E7403043O00456E756D03123O00536F7572636553616E7353656D69626F6C6403083O005465787453697A65026O003440030A3O0054657874436F6C6F723303063O00436F6C6F723303163O00546578745374726F6B655472616E73706172656E6379030E3O005465787459416C69676E6D656E7403063O00426F2O746F6D03043O005465787403063O004E616D653A20030E3O00436861726163746572412O64656403073O00436F2O6E656374030D3O0052656E6465725374652O70656403073O0044657374726F7900FC3O0012283O00013O0026203O00E40001000200041D3O00E400012O002700015O00202O000100010003000655000100FB00013O00041D3O00FB00012O002700015O0020500001000100044O000200013O00202O00020002000500202O00020002000400062O000100FB0001000200041D3O00FB00012O0027000100023O00203A0001000100064O00035O00202O00030003000400122O000400076O0003000300044O00010003000200062O000100FB0001000100041D3O00FB0001001201000100083O00204500010001000900122O0002000A6O0001000200024O00025O00202O00020002000400122O000300076O00020002000300102O0001000400024O000200023O00102O0001000B00020012010002000C3O001224000300026O0002000200014O00025O00202O00020002000300062O0002002200013O00041D3O002200010012010002000D4O002700035O00202O0003000300032O002F0002000200020006550002002200013O00041D3O002200012O002700025O00201200020002000300202O00020002000E00122O0004000F6O00020004000200062O0002002200013O00041D3O00220001001201000200104O004400035O00202O00030003000300202O0003000300114O000300046O00023O000400044O006E0001002051000700060012001228000900134O000A0007000900020006550007006E00013O00041D3O006E0001001228000700014O0018000800083O000E390014004A0001000700041D3O004A00012O002700095O00202O000900090016002O1000080015000900041D3O006E00010026200007004F0001000200041D3O004F0001002O100008000B0001002O10000800170006001228000700183O002620000700550001001900041D3O0055000100202O00090006001A002O100008001A00090030460008001B001C001228000700143O002620000700680001000100041D3O00680001001228000900013O000E390002005C0001000900041D3O005C0001001228000700023O00041D3O00680001002620000900580001000100041D3O00580001001201000A00083O002034000A000A000900122O000B001D6O000A000200024O0008000A6O000A5O00202O000A000A000400102O00080004000A00122O000900023O00044O00580001002620000700440001001800041D3O004400010030460008001E001F003046000800200021001228000700193O00041D3O004400010006400002003D0001000200041D3O003D00012O002700025O00202O000200020003000655000200E200013O00041D3O00E200012O002700025O00201200020002000300202O00020002000600122O000400226O00020004000200062O000200E200013O00041D3O00E20001001201000200083O00204200020002000900122O000300236O00020002000200122O000300083O00202O00030003000900122O000400246O0003000200024O00045O00202O00040004000300202O00040004002200102O0002001700044O00045O00202O00040004000400102O00020004000400102O0002000B000100122O000400253O00202O00040004000900122O000500013O00122O000600263O00122O000700013O00122O000800276O00040008000200102O0002001A000400122O000400293O00202O00040004000900122O000500013O00122O000600023O00122O000700016O00040007000200102O00020028000400302O0002001E001F00102O0003000B000200302O0003002A000200122O000400253O00202O00040004000900122O000500013O00122O000600013O00122O000700013O00122O0008002C6O00040008000200102O0003002B000400122O000400253O00202O00040004000900122O000500013O00122O000600263O00122O000700013O00122O000800266O00040008000200102O0003001A000400122O0004002E3O00202O00040004002D00202O00040004002F00102O0003002D000400302O00030030003100122O000400333O00202O00040004000900122O000500023O00122O000600023O00122O000700026O00040007000200102O00030032000400302O00030034000100122O0004002E3O00202O00040004003500202O00040004003600102O00030035000400122O000400386O00055O00202O0005000500044O00040004000500102O00030037000400302O0003002000214O000400056O00065O00202O00060006003900202O00060006003A00064300083O000100052O00273O00034O00493O00054O00493O00044O00493O00014O00278O000A0006000800022O0049000500063O00064300060001000100072O00273O00024O00278O00273O00034O00273O00014O00493O00034O00493O00054O00493O00044O0027000700033O002620000700E10001001F00041D3O00E100012O0027000700043O00204D00070007003B00202O00070007003A4O000900066O0007000900024O000400074O003300026O003300015O00041D3O00FB00010026203O00010001000100041D3O00010001001201000100104O001C000200023O00202O0002000200114O000200036O00013O000300044O00F5000100202O0006000500042O001A00075O00202O00070007000400122O000800076O00070007000800062O000600F50001000700041D3O00F5000100205100060005003C2O0002000600020001000640000100EC0001000200041D3O00EC00010012010001000C4O000E0001000100010012283O00023O00041D3O000100012O00053O00013O00023O000C3O002O01028O00027O0040030A3O00446973636F2O6E65637403073O0044657374726F79026O00F03F03043O007761697403073O00676574522O6F7403093O0043686172616374657203153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F69642O033O00455350002F4O00277O0026203O002B0001000100041D3O002B00010012283O00023O0026203O000A0001000300041D3O000A00012O0027000100013O0020510001000100042O000200010002000100041D3O002E00010026203O00130001000200041D3O001300012O0027000100023O0020040001000100044O0001000200014O000100033O00202O0001000100054O00010002000100124O00063O0026203O00040001000600041D3O00040001001201000100073O001221000200066O00010002000100122O000100086O000200043O00202O0002000200094O00010002000200062O0001001500013O00041D3O001500012O0027000100043O00201200010001000900202O00010001000A00122O0003000B6O00010003000200062O0001001500013O00041D3O001500010012010001000C4O0027000200044O00020001000200010012283O00033O00041D3O0004000100041D3O002E00012O00273O00013O0020515O00042O00023O000200012O00053O00017O00163O00030E3O0046696E6446697273744368696C6403043O004E616D6503043O005F4553502O0103093O0043686172616374657203073O00676574522O6F7403153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F6964030B3O004C6F63616C506C61796572028O0003043O006D61746803053O00666C2O6F7203083O00506F736974696F6E03093O006D61676E697475646503043O005465787403063O004E616D653A20030B3O00207C204865616C74683A2003053O00726F756E6403063O004865616C7468026O00F03F030A3O00207C2053747564733A20030A3O00446973636F2O6E65637400674O00117O00206O00014O000200013O00202O00020002000200122O000300036O0002000200036O0002000200064O005B00013O00041D3O005B00012O00273O00023O0026203O005B0001000400041D3O005B00012O00273O00013O00206O00050006553O006600013O00041D3O006600010012013O00064O0027000100013O00202O0001000100052O002F3O000200020006553O006600013O00041D3O006600012O00273O00013O0020125O000500206O000700122O000200088O0002000200064O006600013O00041D3O006600012O00273O00033O00206O000900206O00050006553O006600013O00041D3O006600010012013O00064O0030000100033O00202O00010001000900202O0001000100056O0002000200064O006600013O00041D3O006600012O00273O00033O0020295O000900206O000500206O000700122O000200088O0002000200064O006600013O00041D3O006600010012283O000A4O0018000100013O0026203O00330001000A00041D3O003300010012010002000B3O00203200020002000C00122O000300066O000400033O00202O00040004000900202O0004000400054O00030002000200202O00030003000D00122O000400066O000500013O00202O0005000500054O00040002000200202O00040004000D4O00030003000400202O00030003000E4O0002000200024O000100026O000200043O00122O000300106O000400013O00202O00040004000200122O000500113O00122O000600126O000700013O00202O00070007000500202O00070007000700122O000900086O00070009000200202O00070007001300122O000800146O00060008000200122O000700156O000800016O00030003000800102O0002000F000300044O0066000100041D3O0033000100041D3O006600010012283O000A3O0026203O005C0001000A00041D3O005C00012O0027000100053O00202C0001000100164O0001000200014O000100063O00202O0001000100164O00010002000100044O0066000100041D3O005C00012O00053O00017O00", GetFEnv(), ...);
