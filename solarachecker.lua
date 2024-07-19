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
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_95CAC = 0;
				local b;
				while true do
					if (FlatIdent_95CAC == 1) then
						return b;
					end
					if (FlatIdent_95CAC == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_95CAC = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local FlatIdent_8D327 = 0;
		local a;
		while true do
			if (FlatIdent_8D327 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_8D327 = 1;
			end
			if (FlatIdent_8D327 == 1) then
				return a;
			end
		end
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
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_67C40 = 0;
			while true do
				if (FlatIdent_67C40 == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
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
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_89ECE = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_89ECE == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
					if (FlatIdent_89ECE == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_89ECE = 3;
					end
					if (FlatIdent_89ECE == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
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
						FlatIdent_89ECE = 2;
					end
					if (FlatIdent_89ECE == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_89ECE = 1;
					end
				end
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
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 43) then
					if (Enum <= 21) then
						if (Enum <= 10) then
							if (Enum <= 4) then
								if (Enum <= 1) then
									if (Enum == 0) then
										Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
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
											local FlatIdent_8199B = 0;
											while true do
												if (FlatIdent_8199B == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 2) then
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
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								elseif (Enum > 3) then
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
								else
									local FlatIdent_39B0 = 0;
									local NewProto;
									local NewUvals;
									local Indexes;
									while true do
										if (FlatIdent_39B0 == 2) then
											for Idx = 1, Inst[4] do
												local FlatIdent_1BCFB = 0;
												local Mvm;
												while true do
													if (FlatIdent_1BCFB == 1) then
														if (Mvm[1] == 76) then
															Indexes[Idx - 1] = {Stk,Mvm[3]};
														else
															Indexes[Idx - 1] = {Upvalues,Mvm[3]};
														end
														Lupvals[#Lupvals + 1] = Indexes;
														break;
													end
													if (FlatIdent_1BCFB == 0) then
														VIP = VIP + 1;
														Mvm = Instr[VIP];
														FlatIdent_1BCFB = 1;
													end
												end
											end
											Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
											break;
										end
										if (FlatIdent_39B0 == 0) then
											NewProto = Proto[Inst[3]];
											NewUvals = nil;
											FlatIdent_39B0 = 1;
										end
										if (FlatIdent_39B0 == 1) then
											Indexes = {};
											NewUvals = Setmetatable({}, {__index=function(_, Key)
												local Val = Indexes[Key];
												return Val[1][Val[2]];
											end,__newindex=function(_, Key, Value)
												local FlatIdent_51F42 = 0;
												local Val;
												while true do
													if (FlatIdent_51F42 == 0) then
														Val = Indexes[Key];
														Val[1][Val[2]] = Value;
														break;
													end
												end
											end});
											FlatIdent_39B0 = 2;
										end
									end
								end
							elseif (Enum <= 7) then
								if (Enum <= 5) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
								elseif (Enum == 6) then
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
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									Env[Inst[3]] = Stk[Inst[2]];
								end
							elseif (Enum <= 8) then
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							elseif (Enum > 9) then
								local FlatIdent_27957 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_27957 == 8) then
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_27957 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_27957 = 5;
									end
									if (FlatIdent_27957 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_27957 = 4;
									end
									if (FlatIdent_27957 == 6) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_27957 = 7;
									end
									if (FlatIdent_27957 == 5) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_27957 = 6;
									end
									if (FlatIdent_27957 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_27957 = 1;
									end
									if (FlatIdent_27957 == 7) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_27957 = 8;
									end
									if (FlatIdent_27957 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_27957 = 2;
									end
									if (FlatIdent_27957 == 2) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_27957 = 3;
									end
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
						elseif (Enum <= 15) then
							if (Enum <= 12) then
								if (Enum > 11) then
									local FlatIdent_66799 = 0;
									local A;
									while true do
										if (FlatIdent_66799 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_66799 = 1;
										end
										if (FlatIdent_66799 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (2 == FlatIdent_66799) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_66799 = 3;
										end
										if (FlatIdent_66799 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_66799 = 2;
										end
									end
								else
									local FlatIdent_27404 = 0;
									local Edx;
									local Results;
									local B;
									local A;
									while true do
										if (FlatIdent_27404 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_27404 = 6;
										end
										if (FlatIdent_27404 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_27404 == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_27404 = 4;
										end
										if (FlatIdent_27404 == 0) then
											Edx = nil;
											Results = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_27404 = 1;
										end
										if (FlatIdent_27404 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_27404 = 2;
										end
										if (FlatIdent_27404 == 4) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_27404 = 5;
										end
										if (FlatIdent_27404 == 2) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_27404 = 3;
										end
									end
								end
							elseif (Enum <= 13) then
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
							elseif (Enum > 14) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							elseif not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 18) then
							if (Enum <= 16) then
								local FlatIdent_8A742 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_8A742 == 5) then
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (2 == FlatIdent_8A742) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_8A742 = 3;
									end
									if (FlatIdent_8A742 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_8A742 = 5;
									end
									if (FlatIdent_8A742 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8A742 = 1;
									end
									if (FlatIdent_8A742 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8A742 = 4;
									end
									if (FlatIdent_8A742 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8A742 = 2;
									end
								end
							elseif (Enum == 17) then
								local A = Inst[2];
								local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								local Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_8BC55 = 0;
									while true do
										if (FlatIdent_8BC55 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							else
								local K;
								local B;
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
								if (Stk[Inst[2]] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 19) then
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
						elseif (Enum > 20) then
							local A = Inst[2];
							local Cls = {};
							for Idx = 1, #Lupvals do
								local List = Lupvals[Idx];
								for Idz = 0, #List do
									local Upv = List[Idz];
									local NStk = Upv[1];
									local DIP = Upv[2];
									if ((NStk == Stk) and (DIP >= A)) then
										Cls[DIP] = NStk[DIP];
										Upv[1] = Cls;
									end
								end
							end
						else
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						end
					elseif (Enum <= 32) then
						if (Enum <= 26) then
							if (Enum <= 23) then
								if (Enum == 22) then
									local Results;
									local Edx;
									local Results, Limit;
									local B;
									local A;
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
									A = Inst[2];
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_19F98 = 0;
										while true do
											if (FlatIdent_19F98 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_75224 = 0;
										while true do
											if (FlatIdent_75224 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
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
							elseif (Enum <= 24) then
								local FlatIdent_22216 = 0;
								local A;
								while true do
									if (FlatIdent_22216 == 1) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_22216 = 2;
									end
									if (FlatIdent_22216 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_22216 == 0) then
										A = nil;
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_22216 = 1;
									end
									if (FlatIdent_22216 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_22216 = 3;
									end
								end
							elseif (Enum == 25) then
								do
									return;
								end
							else
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
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
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
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
							end
						elseif (Enum <= 29) then
							if (Enum <= 27) then
								Upvalues[Inst[3]] = Stk[Inst[2]];
							elseif (Enum == 28) then
								local FlatIdent_32B97 = 0;
								local A;
								local B;
								while true do
									if (FlatIdent_32B97 == 0) then
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_32B97 = 1;
									end
									if (FlatIdent_32B97 == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
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
						elseif (Enum <= 30) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
						elseif (Enum > 31) then
							local FlatIdent_580CB = 0;
							local A;
							while true do
								if (FlatIdent_580CB == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_580CB = 1;
								end
								if (FlatIdent_580CB == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_580CB = 4;
								end
								if (FlatIdent_580CB == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_580CB = 3;
								end
								if (4 == FlatIdent_580CB) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_580CB = 5;
								end
								if (FlatIdent_580CB == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_580CB = 7;
								end
								if (8 == FlatIdent_580CB) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_580CB == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_580CB = 2;
								end
								if (FlatIdent_580CB == 5) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_580CB = 6;
								end
								if (FlatIdent_580CB == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_580CB = 8;
								end
							end
						elseif Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 37) then
						if (Enum <= 34) then
							if (Enum == 33) then
								if (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
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
						elseif (Enum <= 35) then
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
						elseif (Enum > 36) then
							Stk[Inst[2]] = not Stk[Inst[3]];
						elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 40) then
						if (Enum <= 38) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						elseif (Enum == 39) then
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						elseif (Stk[Inst[2]] == Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 41) then
						local B = Stk[Inst[4]];
						if not B then
							VIP = VIP + 1;
						else
							local FlatIdent_6AEED = 0;
							while true do
								if (FlatIdent_6AEED == 0) then
									Stk[Inst[2]] = B;
									VIP = Inst[3];
									break;
								end
							end
						end
					elseif (Enum > 42) then
						local FlatIdent_5E109 = 0;
						local A;
						local Results;
						local Limit;
						local Edx;
						while true do
							if (FlatIdent_5E109 == 1) then
								Top = (Limit + A) - 1;
								Edx = 0;
								FlatIdent_5E109 = 2;
							end
							if (FlatIdent_5E109 == 2) then
								for Idx = A, Top do
									local FlatIdent_53124 = 0;
									while true do
										if (FlatIdent_53124 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								break;
							end
							if (FlatIdent_5E109 == 0) then
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								FlatIdent_5E109 = 1;
							end
						end
					else
						local FlatIdent_44603 = 0;
						local A;
						while true do
							if (2 == FlatIdent_44603) then
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_44603 = 3;
							end
							if (4 == FlatIdent_44603) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_44603 = 5;
							end
							if (1 == FlatIdent_44603) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_44603 = 2;
							end
							if (FlatIdent_44603 == 5) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_44603 == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_44603 = 1;
							end
							if (FlatIdent_44603 == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_44603 = 4;
							end
						end
					end
				elseif (Enum <= 65) then
					if (Enum <= 54) then
						if (Enum <= 48) then
							if (Enum <= 45) then
								if (Enum > 44) then
									local FlatIdent_8FBAE = 0;
									local A;
									while true do
										if (FlatIdent_8FBAE == 0) then
											A = Inst[2];
											do
												return Unpack(Stk, A, Top);
											end
											break;
										end
									end
								else
									local FlatIdent_44100 = 0;
									local A;
									while true do
										if (FlatIdent_44100 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
									end
								end
							elseif (Enum <= 46) then
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
							elseif (Enum > 47) then
								local A = Inst[2];
								do
									return Unpack(Stk, A, A + Inst[3]);
								end
							else
								local K;
								local B;
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
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 51) then
							if (Enum <= 49) then
								Stk[Inst[2]] = {};
							elseif (Enum > 50) then
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
							else
								local A = Inst[2];
								do
									return Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							end
						elseif (Enum <= 52) then
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
								local FlatIdent_4D83A = 0;
								while true do
									if (FlatIdent_4D83A == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results = {Stk[A](Unpack(Stk, A + 1, Top))};
							Edx = 0;
							for Idx = A, Inst[4] do
								local FlatIdent_956D = 0;
								while true do
									if (FlatIdent_956D == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						elseif (Enum > 53) then
							local A = Inst[2];
							Stk[A] = Stk[A]();
						else
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
						end
					elseif (Enum <= 59) then
						if (Enum <= 56) then
							if (Enum == 55) then
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
							else
								local FlatIdent_3B868 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_3B868 == 6) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3B868 = 7;
									end
									if (FlatIdent_3B868 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_3B868 = 2;
									end
									if (FlatIdent_3B868 == 3) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_3B868 = 4;
									end
									if (4 == FlatIdent_3B868) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_3B868 = 5;
									end
									if (FlatIdent_3B868 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_3B868 = 6;
									end
									if (2 == FlatIdent_3B868) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_3B868 = 3;
									end
									if (9 == FlatIdent_3B868) then
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_3B868 == 7) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3B868 = 8;
									end
									if (FlatIdent_3B868 == 8) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_3B868 = 9;
									end
									if (FlatIdent_3B868 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_3B868 = 1;
									end
								end
							end
						elseif (Enum <= 57) then
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
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
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
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
						elseif (Enum == 58) then
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
							local FlatIdent_8EA6E = 0;
							local A;
							local Results;
							local Edx;
							while true do
								if (FlatIdent_8EA6E == 0) then
									A = Inst[2];
									Results = {Stk[A](Stk[A + 1])};
									FlatIdent_8EA6E = 1;
								end
								if (FlatIdent_8EA6E == 1) then
									Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									break;
								end
							end
						end
					elseif (Enum <= 62) then
						if (Enum <= 60) then
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
						elseif (Enum > 61) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						else
							local B = Inst[3];
							local K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
						end
					elseif (Enum <= 63) then
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
						VIP = Inst[3];
					elseif (Enum == 64) then
						local K;
						local B;
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
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
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
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
					else
						local FlatIdent_1BA2F = 0;
						while true do
							if (FlatIdent_1BA2F == 2) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1BA2F = 3;
							end
							if (FlatIdent_1BA2F == 1) then
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1BA2F = 2;
							end
							if (FlatIdent_1BA2F == 0) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1BA2F = 1;
							end
							if (FlatIdent_1BA2F == 4) then
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
								break;
							end
							if (3 == FlatIdent_1BA2F) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1BA2F = 4;
							end
						end
					end
				elseif (Enum <= 76) then
					if (Enum <= 70) then
						if (Enum <= 67) then
							if (Enum > 66) then
								do
									return Stk[Inst[2]];
								end
							else
								Stk[Inst[2]] = Inst[3] ^ Stk[Inst[4]];
							end
						elseif (Enum <= 68) then
							VIP = Inst[3];
						elseif (Enum > 69) then
							Stk[Inst[2]] = Inst[3];
						else
							local FlatIdent_1BB5D = 0;
							local A;
							while true do
								if (FlatIdent_1BB5D == 1) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_1BB5D = 2;
								end
								if (FlatIdent_1BB5D == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_1BB5D = 6;
								end
								if (FlatIdent_1BB5D == 4) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_1BB5D = 5;
								end
								if (FlatIdent_1BB5D == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_1BB5D = 3;
								end
								if (FlatIdent_1BB5D == 6) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BB5D = 7;
								end
								if (9 == FlatIdent_1BB5D) then
									do
										return;
									end
									break;
								end
								if (FlatIdent_1BB5D == 0) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BB5D = 1;
								end
								if (FlatIdent_1BB5D == 8) then
									A = Inst[2];
									do
										return Unpack(Stk, A, Top);
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BB5D = 9;
								end
								if (FlatIdent_1BB5D == 7) then
									A = Inst[2];
									do
										return Stk[A](Unpack(Stk, A + 1, Inst[3]));
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BB5D = 8;
								end
								if (3 == FlatIdent_1BB5D) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1BB5D = 4;
								end
							end
						end
					elseif (Enum <= 73) then
						if (Enum <= 71) then
							if (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 72) then
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
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						else
							Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
						end
					elseif (Enum <= 74) then
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
					elseif (Enum == 75) then
						Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
					else
						Stk[Inst[2]] = Stk[Inst[3]];
					end
				elseif (Enum <= 81) then
					if (Enum <= 78) then
						if (Enum == 77) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						else
							local FlatIdent_8A9D7 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_8A9D7 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8A9D7 = 2;
								end
								if (3 == FlatIdent_8A9D7) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8A9D7 = 4;
								end
								if (FlatIdent_8A9D7 == 6) then
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_8A9D7 = 7;
								end
								if (FlatIdent_8A9D7 == 8) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									break;
								end
								if (FlatIdent_8A9D7 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8A9D7 = 5;
								end
								if (FlatIdent_8A9D7 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_8A9D7 = 1;
								end
								if (FlatIdent_8A9D7 == 5) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8A9D7 = 6;
								end
								if (FlatIdent_8A9D7 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8A9D7 = 8;
								end
								if (FlatIdent_8A9D7 == 2) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_8A9D7 = 3;
								end
							end
						end
					elseif (Enum <= 79) then
						local A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
					elseif (Enum > 80) then
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
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
				elseif (Enum <= 84) then
					if (Enum <= 82) then
						Stk[Inst[2]]();
					elseif (Enum > 83) then
						local FlatIdent_15034 = 0;
						local Results;
						local Edx;
						local Limit;
						local B;
						local A;
						while true do
							if (1 == FlatIdent_15034) then
								A = nil;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_15034 = 2;
							end
							if (FlatIdent_15034 == 6) then
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (0 == FlatIdent_15034) then
								Results = nil;
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								FlatIdent_15034 = 1;
							end
							if (FlatIdent_15034 == 2) then
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_15034 = 3;
							end
							if (3 == FlatIdent_15034) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								FlatIdent_15034 = 4;
							end
							if (4 == FlatIdent_15034) then
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								FlatIdent_15034 = 5;
							end
							if (FlatIdent_15034 == 5) then
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								FlatIdent_15034 = 6;
							end
						end
					else
						local FlatIdent_74B46 = 0;
						local A;
						while true do
							if (FlatIdent_74B46 == 0) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					end
				elseif (Enum <= 85) then
					local B;
					local A;
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Env[Inst[3]] = Stk[Inst[2]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3] ~= 0;
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Env[Inst[3]] = Stk[Inst[2]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3] ~= 0;
				elseif (Enum == 86) then
					Stk[Inst[2]] = Env[Inst[3]];
				else
					local FlatIdent_30B1F = 0;
					while true do
						if (FlatIdent_30B1F == 1) then
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_30B1F = 2;
						end
						if (FlatIdent_30B1F == 2) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_30B1F = 3;
						end
						if (FlatIdent_30B1F == 3) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_30B1F = 4;
						end
						if (4 == FlatIdent_30B1F) then
							if (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
							break;
						end
						if (FlatIdent_30B1F == 0) then
							Env[Inst[3]] = Stk[Inst[2]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_30B1F = 1;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!253O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F626C2O6F6462612O6C2F2D6261636B2D7570732D666F722D6C6962732F6D61696E2F77697A61726403093O004E657757696E646F77030F3O006E692O676572626561746572363738030A3O004E657753656374696F6E2O033O0041544B03053O004D69736373030C3O007472616E73706172656E637902AE47E17A14AEEF3F2O033O004A2O4B2O033O0065737003023O005F4703083O0044697361626C65642O01030A3O0047657453657276696365030A3O0052756E5365727669636503073O00436F726547756903073O00506C6179657273030D3O0043726561746554657874626F7803063O00486974626F78030A3O006765746E692O67657273030C3O00437265617465546F2O676C6503083O0053686F7720657370030D3O00496E76697320426C7565426F7803073O00676574522O6F7403053O00726F756E642O033O0045535003043O004E616D6503063O00726F626C6F78028O0003043O0077616974026O00F03F030B3O004C6F63616C506C6179657203043O004B69636B030C3O00534F4C415241204C4F3O4C005D3O00121A3O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O0001000200202O00013O000500122O000300066O00010003000200201C000200010007001255000400086O00020004000200202O00030001000700122O000500096O00030005000200122O0004000B3O00122O0004000A6O000400013O00122O0004000C6O00045O0012070004000D3O00124E0004000E3O00302O0004000F001000122O000400023O00202O00040004001100122O000600126O0004000600024O00055O00122O000600023O00202O00060006001300122O000700023O00204D00070007001400201C000800020015001246000A00163O000208000B6O004F0008000B0001000208000800013O001207000800173O00201C000800020018001246000A00193O000603000B0002000100022O004C3O00054O004C3O00064O004F0008000B000100201C000800030018001246000A001A3O000208000B00034O004F0008000B0001000208000800043O0012070008001B3O000208000800053O0012070008001C3O00060300080006000100042O004C3O00064O004C3O00074O004C3O00054O004C3O00043O0012570008001D3O00122O000800023O00202O00080008001400202O00080008001E00262O000800420001001F0004443O004200012O00193O00013O0004443O005B0001001246000800204O0051000900093O00264700080044000100200004443O00440001001246000900203O0026470009004F000100200004443O004F0001001256000A00174O0018000A0001000100122O000A00213O00122O000B00226O000A0002000100122O000900223O00264700090047000100220004443O00470001001256000A00023O002006000A000A001400202O000A000A002300202O000A000A002400122O000C00256O000A000C000100044O005B00010004443O004700010004443O005B00010004443O004400012O00158O00193O00013O00073O00083O00028O0003023O005F4703083O004865616453697A6503043O0067616D65030A3O0047657453657276696365030A3O0052756E53657276696365030D3O0052656E6465725374652O70656403073O00636F2O6E65637401103O001246000100013O00264700010001000100010004443O00010001001256000200023O001038000200033O00122O000200043O00202O00020002000500122O000400066O00020004000200202O00020002000700202O00020002000800020800046O004F0002000400010004443O000F00010004443O000100012O00193O00013O00013O000A3O0003023O005F4703083O0044697361626C656403043O006E65787403043O0067616D65030A3O004765745365727669636503073O00506C6179657273030A3O00476574506C617965727303043O004E616D65030B3O004C6F63616C506C6179657203053O007063612O6C001D3O0012563O00013O00204D5O000200061F3O001C00013O0004443O001C00010012563O00033O00120B000100043O00202O00010001000500122O000300066O00010003000200202O0001000100074O00010002000200044O001A000100204D00050004000800123C000600043O00202O00060006000500122O000800066O00060008000200202O00060006000900202O00060006000800062O00050019000100060004443O001900010012560005000A3O00060300063O000100012O004C3O00044O00270005000200012O001500035O0006503O000C000100020004443O000C00012O00193O00013O00013O00123O00028O0003093O0043686172616374657203103O0048756D616E6F6964522O6F745061727403043O0053697A6503073O00566563746F72332O033O006E657703023O005F4703083O004865616453697A65030C3O005472616E73706172656E6379030C3O007472616E73706172656E6379026O00F03F030A3O00427269636B436F6C6F72030B3O005265612O6C7920626C756503083O004D6174657269616C03043O004E656F6E027O0040030A3O0043616E436F2O6C696465012O00343O0012463O00014O0051000100013O0026473O0002000100010004443O00020001001246000100013O0026470001001A000100010004443O001A00012O000500025O002O2000020002000200202O00020002000300122O000300053O00202O00030003000600122O000400073O00202O00040004000800122O000500073O00202O00050005000800122O000600073O00202O0006000600084O00030006000200102O0002000400034O00025O00202O00020002000200202O00020002000300122O0003000A3O00102O00020009000300122O0001000B3O002647000100290001000B0004443O002900012O000500025O00203900020002000200202O00020002000300122O0003000C3O00202O00030003000600122O0004000D6O00030002000200102O0002000C00034O00025O00202O00020002000200202O00020002000300302O0002000E000F00122O000100103O00264700010005000100100004443O000500012O000500025O00204D00020002000200204D00020002000300301E0002001100120004443O003300010004443O000500010004443O003300010004443O000200012O00193O00017O00133O00028O00027O0040030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E03053O007063612O6C026O00F03F03073O00636F6E74656E7403093O00757365726E616D653A03043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503053O000A2049503A03073O00482O747047657403163O00682O7470733A2O2F6170692E69706966792E6F72672F030A3O004A534F4E456E636F646503793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F313236313538363430323337303532333233362F6778446F70345F786B444935517278382D4B313458645662416D4547446477514B635A304F6A45344C6F50315F4C4A2O5F7167626775734D444D44582D63493858735F6D030A3O0047657453657276696365030B3O00482O74705365727669636500403O0012463O00014O0051000100073O0026473O0010000100020004443O001000012O003100083O000100301E0008000300042O004C000500083O001256000800053O00060300093O000100032O004C3O00014O004C3O00044O004C3O00054O003B0008000200092O004C000700094O004C000600083O0004443O003F00010026473O002D000100060004443O002D0001001246000800013O00264700080017000100060004443O001700010012463O00023O0004443O002D000100264700080013000100010004443O001300012O003100093O0001001249000A00083O00122O000B00093O00202O000B000B000A00202O000B000B000B00202O000B000B000C00122O000C000D3O00122O000D00093O00202O000D000D000E00122O000F000F6O000D000F00024O000A000A000D00102O00090007000A4O000300093O00202O0009000200104O000B00036O0009000B00024O000400093O00122O000800063O00044O001300010026473O0002000100010004443O00020001001246000800013O00264700080034000100060004443O003400010012463O00063O0004443O0002000100264700080030000100010004443O00300001001246000100113O00120A000900093O00202O00090009001200122O000B00136O0009000B00024O000200093O00122O000800063O00044O003000010004443O000200012O00193O00013O00013O00063O0003073O00726571756573742O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273000C3O0012453O00016O00013O00044O00025O00102O0001000200024O000200013O00102O00010003000200302O0001000400054O000200023O00102O0001000600026O00019O008O00017O000F3O00028O002O0103053O00706169727303043O0067616D6503073O00506C6179657273030A3O00476574506C617965727303043O004E616D65030B3O004C6F63616C506C617965722O033O00455350030B3O004765744368696C6472656E03063O00737472696E672O033O00737562026O0010C003043O005F45535003073O0044657374726F7901313O001246000100013O00264700010001000100010004443O000100012O000500026O0025000200024O001B00026O000500025O0026470002001D000100020004443O001D0001001256000200033O001234000300043O00202O00030003000500202O0003000300064O000300046O00023O000400044O001A000100204D000700060007001237000800043O00202O00080008000500202O00080008000800202O00080008000700062O0007001A000100080004443O001A0001001256000700094O004C000800064O002700070002000100065000020010000100020004443O001000010004443O00300001001256000200034O0001000300013O00202O00030003000A4O000300046O00023O000400044O002C00010012560007000B3O00200C00070007000C00202O00080006000700122O0009000D6O00070009000200262O0007002C0001000E0004443O002C000100201C00070006000F2O002700070002000100065000020023000100020004443O002300010004443O003000010004443O000100012O00193O00017O00073O00028O002O033O004A2O4B0100030C3O007472616E73706172656E6379026O00F03F2O0102AE47E17A14AEEF3F01143O001246000100013O00264700010001000100010004443O00010001001256000200024O0025000200023O001207000200023O001256000200023O0026470002000C000100030004443O000C0001001246000200053O001207000200043O0004443O00130001001256000200023O00264700020013000100060004443O00130001001246000200073O001207000200043O0004443O001300010004443O000100012O00193O00017O00053O00028O00030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403053O00546F72736F030A3O00552O706572546F72736F01153O001246000100014O0051000200023O00264700010002000100010004443O0002000100201C00033O0002001246000500034O005300030005000200062900020012000100030004443O0012000100201C00033O0002001246000500044O005300030005000200062900020012000100030004443O0012000100201C00033O0002001246000500054O00530003000500022O004C000200034O0043000200023O0004443O000200012O00193O00017O00053O00028O00026O00244003043O006D61746803053O00666C2O6F72026O00E03F02153O001246000200014O0051000300033O00264700020002000100010004443O00020001001246000400013O00264700040005000100010004443O000500010006290005000A000100010004443O000A0001001246000500013O001042000300020005001222000500033O00202O0005000500044O00063O000300202O0006000600054O0005000200024O0005000500034O000500023O00044O000500010004443O000200012O00193O00017O00023O0003043O007461736B03053O00737061776E010A3O001256000100013O00204D00010001000200060300023O000100052O00058O004C8O00053O00014O00053O00024O00053O00034O00270001000200012O00193O00013O00013O003C3O00028O0003053O007061697273030B3O004765744368696C6472656E03043O004E616D6503043O005F45535003073O0044657374726F7903043O0077616974026O00F03F03093O00436861726163746572030B3O004C6F63616C506C61796572030E3O0046696E6446697273744368696C6403083O00496E7374616E63652O033O006E657703063O00466F6C64657203063O00506172656E7403073O00676574522O6F7403153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F69642O033O0049734103083O00426173655061727403123O00426F7848616E646C6541646F726E6D656E7403073O0041646F726E2O65027O0040026O00104003053O00436F6C6F7203093O005465616D436F6C6F72026O00084003043O0053697A65030C3O005472616E73706172656E6379026O66EE3F030B3O00416C776179734F6E546F702O0103063O005A496E646578026O00244003043O0048656164030C3O0042692O6C626F61726447756903093O00546578744C6162656C03053O005544696D32026O005940025O00C06240030B3O0053747564734F2O6673657403073O00566563746F723303163O004261636B67726F756E645472616E73706172656E637903083O00506F736974696F6E026O0049C003043O00466F6E7403043O00456E756D03123O00536F7572636553616E7353656D69626F6C6403083O005465787453697A65026O003440030A3O0054657874436F6C6F723303063O00436F6C6F723303163O00546578745374726F6B655472616E73706172656E6379030E3O005465787459416C69676E6D656E7403063O00426F2O746F6D03043O005465787403063O004E616D653A20030E3O00436861726163746572412O64656403073O00436F2O6E656374030D3O0052656E6465725374652O70656400F43O0012463O00013O0026473O0017000100010004443O00170001001256000100024O000100025O00202O0002000200034O000200036O00013O000300044O0012000100204D0006000500042O0012000700013O00202O00070007000400122O000800056O00070007000800062O00060012000100070004443O0012000100201C0006000500062O002700060002000100065000010009000100020004443O00090001001256000100074O00520001000100010012463O00083O0026473O0001000100080004443O000100012O0005000100013O00204D00010001000900061F000100F300013O0004443O00F300012O0005000100013O0020410001000100044O000200023O00202O00020002000A00202O00020002000400062O000100F3000100020004443O00F300012O000500015O00200400010001000B4O000300013O00202O00030003000400122O000400056O0003000300044O00010003000200062O000100F3000100010004443O00F300010012560001000C3O00202F00010001000D00122O0002000E6O0001000200024O000200013O00202O00020002000400122O000300056O00020002000300102O0001000400024O00025O00102O0001000F0002001256000200073O001235000300086O0002000200014O000200013O00202O00020002000900062O0002003800013O0004443O00380001001256000200104O0005000300013O00204D0003000300092O002C00020002000200061F0002003800013O0004443O003800012O0005000200013O00203A00020002000900202O00020002001100122O000400126O00020004000200062O0002003800013O0004443O00380001001256000200024O0016000300013O00202O00030003000900202O0003000300034O000300046O00023O000400044O007C000100201C000700060013001246000900144O005300070009000200061F0007007C00013O0004443O007C0001001246000700014O0051000800083O00264700070065000100010004443O006500010012560009000C3O00202A00090009000D00122O000A00156O0009000200024O000800096O000900013O00202O00090009000400102O00080004000900122O000700083O0026470007006A000100080004443O006A00010010260008000F0001001026000800160006001246000700173O00264700070070000100180004443O007000012O0005000900013O00204D00090009001A0010260008001900090004443O007C0001002647000700760001001B0004443O0076000100204D00090006001C0010260008001C000900301E0008001D001E001246000700183O0026470007005A000100170004443O005A000100301E0008001F002000301E0008002100220012460007001B3O0004443O005A000100065000020053000100020004443O005300012O0005000200013O00204D00020002000900061F000200F000013O0004443O00F000012O0005000200013O00203A00020002000900202O00020002000B00122O000400236O00020004000200062O000200F000013O0004443O00F000010012560002000C3O00204000020002000D00122O000300246O00020002000200122O0003000C3O00202O00030003000D00122O000400256O0003000200024O000400013O00202O00040004000900202O00040004002300102O0002001600044O000400013O00202O00040004000400102O00020004000400102O0002000F000100122O000400263O00202O00040004000D00122O000500013O00122O000600273O00122O000700013O00122O000800286O00040008000200102O0002001C000400122O0004002A3O00202O00040004000D00122O000500013O00122O000600083O00122O000700016O00040007000200102O00020029000400302O0002001F002000102O0003000F000200302O0003002B000800122O000400263O00202O00040004000D00122O000500013O00122O000600013O00122O000700013O00122O0008002D6O00040008000200102O0003002C000400122O000400263O00202O00040004000D00122O000500013O00122O000600273O00122O000700013O00122O000800276O00040008000200102O0003001C000400122O0004002F3O00202O00040004002E00202O00040004003000102O0003002E000400302O00030031003200122O000400343O00202O00040004000D00122O000500083O00122O000600083O00122O000700086O00040007000200102O00030033000400302O00030035000100122O0004002F3O00202O00040004003600202O00040004003700102O00030036000400122O000400396O000500013O00202O0005000500044O00040004000500102O00030038000400302O0003002100224O000400056O000600013O00202O00060006003A00202O00060006003B00060300083O000100052O00053O00034O004C3O00054O00053O00014O004C3O00044O004C3O00014O00530006000800022O004C000500063O00060300060001000100072O00058O00053O00014O00053O00034O00053O00024O004C3O00034O004C3O00054O004C3O00044O0005000700033O002647000700EF000100200004443O00EF00012O0005000700043O00200D00070007003C00202O00070007003B4O000900066O0007000900024O000400074O001500026O001500015O0004443O00F300010004443O000100012O00193O00013O00023O000C3O002O01028O00027O0040030A3O00446973636F2O6E656374026O00F03F03043O007761697403073O00676574522O6F7403093O0043686172616374657203153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F69642O033O0045535003073O0044657374726F7900354O00057O0026473O0031000100010004443O003100010012463O00024O0051000100013O0026473O0005000100020004443O00050001001246000100023O000E210003000E000100010004443O000E00012O0005000200013O00201C0002000200042O00270002000200010004443O0034000100264700010024000100050004443O00240001001256000200063O001209000300056O00020002000100122O000200076O000300023O00202O0003000300084O00020002000200062O0002001000013O0004443O001000012O0005000200023O00203A00020002000800202O00020002000900122O0004000A6O00020004000200062O0002001000013O0004443O001000010012560002000B4O0005000300024O0027000200020001001246000100033O00264700010008000100020004443O000800012O0005000200033O0020020002000200044O0002000200014O000200043O00202O00020002000C4O00020002000100122O000100053O00044O000800010004443O003400010004443O000500010004443O003400012O00053O00013O00201C5O00042O00273O000200012O00193O00017O00163O00030E3O0046696E6446697273744368696C6403043O004E616D6503043O005F4553502O0103093O0043686172616374657203073O00676574522O6F7403153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F6964030B3O004C6F63616C506C61796572028O0003043O006D61746803053O00666C2O6F7203083O00506F736974696F6E03093O006D61676E697475646503043O005465787403063O004E616D653A20030B3O00207C204865616C74683A2003053O00726F756E6403063O004865616C7468026O00F03F030A3O00207C2053747564733A20030A3O00446973636F2O6E656374006D4O00337O00206O00014O000200013O00202O00020002000200122O000300036O0002000200036O0002000200064O005B00013O0004443O005B00012O00053O00023O0026473O005B000100040004443O005B00012O00053O00013O00204D5O000500061F3O006C00013O0004443O006C00010012563O00064O0005000100013O00204D0001000100052O002C3O0002000200061F3O006C00013O0004443O006C00012O00053O00013O00203A5O000500206O000700122O000200088O0002000200064O006C00013O0004443O006C00012O00053O00033O00204D5O000900204D5O000500061F3O006C00013O0004443O006C00010012563O00064O0013000100033O00202O00010001000900202O0001000100056O0002000200064O006C00013O0004443O006C00012O00053O00033O0020105O000900206O000500206O000700122O000200088O0002000200064O006C00013O0004443O006C00010012463O000A4O0051000100013O0026473O00330001000A0004443O003300010012560002000B3O00204A00020002000C00122O000300066O000400033O00202O00040004000900202O0004000400054O00030002000200202O00030003000D00122O000400066O000500013O00202O0005000500054O00040002000200202O00040004000D4O00030003000400202O00030003000E4O0002000200024O000100026O000200043O00122O000300106O000400013O00202O00040004000200122O000500113O00122O000600126O000700013O00202O00070007000500202O00070007000700122O000900086O00070009000200202O00070007001300122O000800146O00060008000200122O000700156O000800016O00030003000800102O0002000F000300044O006C00010004443O003300010004443O006C00010012463O000A4O0051000100013O0026473O005D0001000A0004443O005D00010012460001000A3O002647000100600001000A0004443O006000012O0005000200053O00203F0002000200164O0002000200014O000200063O00202O0002000200164O00020002000100044O006C00010004443O006000010004443O006C00010004443O005D00012O00193O00017O00", GetFEnv(), ...);
