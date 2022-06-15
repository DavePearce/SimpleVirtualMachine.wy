module Int {
    const MAX_U8 : int := 0x1_00;
    const MAX_U16 : int := 0x1_0000;
    const MAX_U32 : int := 0x1_0000_0000;

    newtype{:nativeType "byte"} u8 = i:int | 0 <= i < MAX_U8
    newtype{:nativeType "ushort"} u16 = i:int | 0 <= i < MAX_U16
    newtype{:nativeType "uint"} uint32 = i:int | 0 <= i < MAX_U32
}
