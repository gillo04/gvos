nasm -f bin boot.asm -o .\bin\boot.bin
nasm -f bin file_list.asm -o .\bin\file_list.bin
nasm -f bin kernel.asm -o .\bin\kernel.bin
nasm -f bin calc.asm -o .\bin\calc.bin
nasm -f bin tris.asm -o .\bin\tris.bin
nasm -f bin document.asm -o .\bin\document.bin
nasm -f bin editor.asm -o .\bin\editor.bin
nasm -f bin numbers.asm -o .\bin\numbers.bin
copy /b bin\boot.bin + bin\file_list.bin + bin\kernel.bin + bin\calc.bin + bin\tris.bin + bin\document.bin + bin\numbers.bin + bin\editor.bin "bin\gvos.bin"
copy bin\gvos.bin gvos.img