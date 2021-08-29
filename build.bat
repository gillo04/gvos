nasm -f bin boot.asm -o bin/boot.bin
nasm -f bin file_list.asm -o bin/file_list.bin
nasm -f bin kernel.asm -o bin/kernel.bin
nasm -f bin test.asm -o bin/test.bin
nasm -f bin edit.asm -o bin/edit.bin
nasm -f bin doc.asm -o bin/doc.bin

copy /b bin\boot.bin + bin\file_list.bin + bin\kernel.bin + bin\test.bin + bin\edit.bin + bin\doc.bin gvos3.img