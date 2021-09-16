;;; -------------------------------------------------------
;;;                     FONT FORMAT
;;; -------------------------------------------------------

;   Number of points
;   x 0, y 0
;   ...
;   x n, y n
;   Number of connections
;   c0 0, c1 0
;   ...
;   c0 n, c1 n

; A
font:

dw f_end65 - $
db 5
db 0, 8
db 2, 0
db 4, 8
db 1, 4
db 3, 4
db 3
db 0, 1
db 1, 2
db 3, 4
f_end65:

; B
dw f_end66 - $
db 10
db 0, 0
db 3, 0
db 4, 1
db 4, 3
db 3, 4
db 0, 4
db 4, 5
db 4, 7
db 3, 8
db 0, 8
db 10
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 4, 6
db 6, 7
db 7, 8
db 8, 9
db 9, 0
f_end66:

; C
dw f_end67 - $
db 6
db 4, 0
db 2, 0
db 0, 2
db 0, 6
db 2, 8
db 4, 8
db 5
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
f_end67:

; D
dw f_end68 - $
db 6
db 0, 0
db 2, 0
db 4, 2
db 4, 6
db 2, 8
db 0, 8
db 6
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 5, 0
f_end68:

; E
dw f_end69 - $
db 6
db 0, 0
db 4, 0
db 0, 4
db 4, 4
db 0, 8
db 4, 8
db 4
db 0, 1
db 2, 3
db 4, 5
db 0, 4
f_end69:

; F
dw f_end70 - $
db 5
db 0, 0
db 4, 0
db 0, 4
db 4, 4
db 0, 8
db 3
db 0, 1
db 2, 3
db 4, 0
f_end70:

; G
dw f_end71 - $
db 8
db 4, 0
db 2, 0
db 0, 2
db 0, 6
db 2, 8
db 4, 8
db 4, 4
db 2, 4
db 7
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 5, 6
db 6, 7
f_end71:

; H
dw f_end72 - $
db 6
db 0, 0
db 0, 8
db 4, 0
db 4, 8
db 0, 4
db 4, 4
db 3
db 0, 1
db 2, 3
db 4, 5
f_end72:

; I
dw f_end73 - $
db 2
db 2, 0
db 2, 8
db 1
db 0, 1
f_end73:

; J
dw f_end74 - $
db 6
db 0, 0
db 4, 0
db 4, 6
db 2, 8
db 0, 6
db 0, 5
db 5
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
f_end74:

; K
dw f_end75 - $
db 5
db 0, 0
db 0, 8
db 4, 0
db 0, 4
db 4, 8
db 3
db 0, 1
db 2, 3
db 3, 4
f_end75:

; L
dw f_end76 - $
db 3
db 0, 0
db 0, 8
db 4, 8
db 2
db 0, 1
db 1, 2
f_end76:

; M
dw f_end77 - $
db 5
db 0, 8
db 0, 0
db 2, 3
db 4, 0
db 4, 8
db 4
db 0, 1
db 1, 2
db 2, 3
db 3, 4
f_end77:

; N
dw f_end78 - $
db 4
db 0, 8
db 0, 0
db 4, 8
db 4, 0
db 3
db 0, 1
db 1, 2
db 2, 3
f_end78:

; O
dw f_end79 - $
db 6
db 2, 0
db 4, 2
db 4, 6
db 2, 8
db 0, 6
db 0, 2
db 6
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 5, 0
f_end79:

; P
dw f_end80 - $
db 7
db 0, 0
db 3, 0
db 4, 1
db 4, 3
db 3, 4
db 0, 4
db 0, 8
db 6
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 6, 0
f_end80:

; Q
dw f_end81 - $
db 8
db 2, 0
db 4, 2
db 4, 6
db 2, 8
db 0, 6
db 0, 2
db 2, 6
db 4, 8
db 7
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 5, 0
db 6, 7
f_end81:

; R
dw f_end82 - $
db 8
db 0, 0
db 3, 0
db 4, 1
db 4, 3
db 3, 4
db 0, 4
db 4, 8
db 0, 8
db 7
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 5, 6
db 7, 0
f_end82:

; S
dw f_end83 - $
db 10
db 4, 0
db 1, 0
db 0, 1
db 0, 3
db 1, 4
db 3, 4
db 4, 5
db 4, 7
db 3, 8
db 0, 8
db 9
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
db 5, 6
db 6, 7
db 7, 8
db 8, 9
f_end83:

; T
dw f_end84 - $
db 4
db 0, 0
db 4, 0
db 2, 0
db 2, 8
db 2
db 0, 1
db 2, 3
f_end84:

; U
dw f_end85 - $
db 6
db 0, 0
db 0, 7
db 1, 8
db 3, 8
db 4, 7
db 4, 0
db 5
db 0, 1
db 1, 2
db 2, 3
db 3, 4
db 4, 5
f_end85:

; V
dw f_end86 - $
db 3
db 0, 0
db 2, 8
db 4, 0
db 2
db 0, 1
db 1, 2
f_end86:

; W
dw f_end87 - $
db 5
db 0, 0
db 1, 8
db 2, 2
db 3, 8
db 4, 0
db 4
db 0, 1
db 1, 2
db 2, 3
db 3, 4
f_end87:

; X
dw f_end88 - $
db 4
db 0, 0
db 4, 8
db 4, 0
db 0, 8
db 2
db 0, 1
db 2, 3
f_end88:

; Y
dw f_end89 - $
db 4
db 0, 0
db 2, 4
db 4, 0
db 0, 8
db 2
db 0, 1
db 2, 3
f_end89:

; Z
dw f_end90 - $
db 4
db 0, 0
db 4, 0
db 0, 8
db 4, 8
db 3
db 0, 1
db 1, 2
db 2, 3
f_end90:

times 512*2 - ($ - $$) db 0