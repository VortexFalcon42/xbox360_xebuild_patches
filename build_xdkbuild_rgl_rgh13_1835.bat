@echo off

echo ***************************************
echo * Xbox 360 XeBuild Patch Set Building *
echo ***************************************
echo.

if exist output rmdir /S /Q output

mkdir output

echo Building kernel patch files...

call :buildPatchSection src\KHV\17489_RGLoader khv_vfuses_sb
call :buildPatchSection src\KHV\17489_RGLoader khv_vfuses_flash

call :buildPatchSection src\KHV\17489_XDKBuild khv_vfuses_sb
call :buildPatchSection src\KHV\17489_XDKBuild khv_vfuses_flash

echo Done!

echo.
echo Building 4BL patch files...

call :buildPatchSection src\4BL\17489 sd_vfuses_bb
call :buildPatchSection src\4BL\17489 sd_vfuses_sb

echo Done!

echo.
echo Building 2BL patch files...

call :buildPatchSection src\2BL\1835 sb_vfuses_rgh13_01w
call :buildPatchSection src\2BL\1835 sb_copyfuses_rgh13_01w

echo Done!

echo.
echo Assembling XeBuild patch sets...

echo.
echo 17489 RGLoader RGH 1.3 vfuses...

mkdir output\17489_RGLoader_RGH1.3_vfuses

REM *** For RGLoader, the patch sets for 16mb machines are all identical as they use the same loaders and kernel
copy /b src\2BL\1835\sb_vfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_sb.bin + src\KHV\17489_RGLoader\khv_vfuses_sb.bin output\17489_RGLoader_RGH1.3_vfuses\patches_g2mjasper.bin
copy output\17489_RGLoader_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_vfuses\patches_g2mxenon.bin
copy output\17489_RGLoader_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_vfuses\patches_g2mxenon_ELPIS.bin
copy output\17489_RGLoader_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_vfuses\patches_g2mzephyr.bin
copy output\17489_RGLoader_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_vfuses\patches_g2mfalcon.bin

REM *** BB consoles - Jasper only
copy /b src\2BL\1835\sb_vfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_bb.bin + src\KHV\17489_RGLoader\khv_vfuses_flash.bin output\17489_RGLoader_RGH1.3_vfuses\patches_g2mjasper_flash.bin

echo Done!

echo 17489 RGLoader RGH 1.3 copyfuses...

mkdir output\17489_RGLoader_RGH1.3_copyfuses

REM *** For RGLoader, the patch sets for 16mb machines are all identical as they use the same loaders and kernel
copy /b src\2BL\1835\sb_copyfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_sb.bin + src\KHV\17489_RGLoader\khv_vfuses_sb.bin output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mjasper.bin
copy output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mxenon.bin
copy output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mxenon_ELPIS.bin
copy output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mzephyr.bin
copy output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mfalcon.bin

REM *** BB consoles - Jasper only
copy /b src\2BL\1835\sb_copyfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_bb.bin + src\KHV\17489_RGLoader\khv_vfuses_flash.bin output\17489_RGLoader_RGH1.3_copyfuses\patches_g2mjasper_flash.bin

echo Done!

echo 17489 XDKBuild RGH 1.3 vfuses...

mkdir output\17489_XDKBuild_RGH1.3_vfuses

REM *** For XDKBuild, the patch sets for 16mb machines are all identical as they use the same loaders and kernel
copy /b src\2BL\1835\sb_vfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_sb.bin + src\KHV\17489_XDKBuild\khv_vfuses_sb.bin output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mjasper.bin
copy output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mxenon.bin
copy output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mxenon_ELPIS.bin
copy output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mzephyr.bin
copy output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mfalcon.bin

REM *** BB consoles - Jasper only
copy /b src\2BL\1835\sb_vfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_bb.bin + src\KHV\17489_XDKBuild\khv_vfuses_flash.bin output\17489_XDKBuild_RGH1.3_vfuses\patches_g2mjasper_flash.bin

echo Done!

echo 17489 XDKBuild RGH 1.3 copyfuses...

mkdir output\17489_XDKBuild_RGH1.3_copyfuses

REM *** For XDKBuild, the patch sets for 16mb machines are all identical as they use the same loaders and kernel
copy /b src\2BL\1835\sb_copyfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_sb.bin + src\KHV\17489_XDKBuild\khv_vfuses_sb.bin output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mjasper.bin
copy output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mxenon.bin
copy output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mxenon_ELPIS.bin
copy output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mzephyr.bin
copy output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mjasper.bin output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mfalcon.bin

REM *** BB consoles - Jasper only
copy /b src\2BL\1835\sb_copyfuses_rgh13_01w.bin + src\4BL\17489\sd_vfuses_bb.bin + src\KHV\17489_XDKBuild\khv_vfuses_flash.bin output\17489_XDKBuild_RGH1.3_copyfuses\patches_g2mjasper_flash.bin

echo Done!

echo.
echo All Done!

pause
goto:eof

:buildPatchSection
bin\xenon-as.exe %~1\%~2.S -I include -I %~1\inc -o %~1\%~2.bin
bin\xenon-objcopy.exe %~1\%~2.bin -O binary
goto:eof
