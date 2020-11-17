nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
copy /b boot.bin + kernel.bin "gvos.bin"
copy gvos.bin gvos.img