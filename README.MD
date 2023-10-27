# Snake Game
Snake game in 8086 Assembly for DOS.

> Entire game:
> <br><img width="250" src="imgs/snake.png">

>Gameplay:
> <br><img width="400" src="imgs/snake.gif">


Assemble in DOS with MASM.
```
> MASM SNAKE.ASM
> LINK SNAKE.OBJ
> EXE2BIN SNAKE.EXE SNAKE.COM

> SNAKE.COM
```

Qr encode and decode.
```
// Encode
> qrencode -8 -r SNAKE.COM -o snake.png

// Decode
> zbarimg --raw --oneshot -Sbinary snake.png > snake.com
```
