nasm -f bin boot.asm -o bin/boot.bin
nasm -f bin kernel.asm -o bin/kernel.bin
nasm -f bin -I ../ programs/test.asm -o bin/test.bin
nasm -f bin -I ../../ programs/edit/edit.asm -o bin/edit.bin
nasm -f bin -I ../ programs/doc.asm -o bin/doc.bin
nasm -f bin -I ../../ programs/3d/3d.asm -o bin/3d.bin
nasm -f bin -I ../../ programs/calc/calc.asm -o bin/calc.bin
nasm -f bin -I ../ programs/font.asm -o bin/font.bin
nasm -f bin -I ../../ programs/game/game.asm -o bin/game.bin
@REM nasm -f bin -I ../../ programs/cad/cad.asm -o bin/cad.bin

copy /b bin\boot.bin + bin\kernel.bin + bin\test.bin + bin\edit.bin + bin\doc.bin + bin\3d.bin + bin\calc.bin + bin\font.bin + bin\game.bin gvos3.img