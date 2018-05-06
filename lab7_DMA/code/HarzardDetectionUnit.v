module HarzardDetectionUnit(
    input      ID_EX_MemRead,
    input[1:0] IF_ID_RegisterRs,
    input[1:0] IF_ID_RegisterRt,
    input[1:0] ID_EX_RegisterRt,
    
    output HarzardDetection
);
    assign HarzardDetection = ID_EX_MemRead && ( ( ID_EX_RegisterRt == IF_ID_RegisterRs ) || ( ID_EX_RegisterRt == IF_ID_RegisterRt ) );
    
endmodule

/*
if (ID/EX.MemRead and
 ((ID/EX.RegisterRt = IF/ID.RegisterRs) or
 (ID/EX.RegisterRt = IF/ID.RegisterRt)))
 stall the pipeline
 */