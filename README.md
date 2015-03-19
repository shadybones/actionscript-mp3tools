#Actionscript MP3 tools

##Tools for splicing/cutting/saving MP3 files. 
Modifying or creating ID3 tags in MP3 files. All, and I mean ALL, ID3 tag types are handled. Some particularly complex ones are handled as raw binary for the programmer to decode/encode properly. NOT completely tested - pre alpha qualit
Fully Supported: - Embedded Images - All Text Tags (T---,WXXX,IPLS,COMM,USLT,USER)

Partially Supported (main content is binary): - W---,PRIV,UFID,MCDI,SYTC,EQUA,GRID,ENCR,POPM,PCNT,POSS

Others are handled as binary data (complete tag), returned to/expected from the programmer for decode/encode.

ALSO: Included is the ability to modify the inter-frame relationship of MP3s. MP3's exist in "frames" or segments, and modification within a frame is not available, whereas cutting, copying, pasting existing frames is.
Saving ID3's and MP3's or loading them into a SWF at runtime is available

##INCOMPLETE
the code is all there, but so very little of it is debugged.
