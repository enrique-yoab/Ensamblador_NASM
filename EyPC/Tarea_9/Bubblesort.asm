section .data 
arreglo db 11, 58, 15, 3, 8                           ;Arreglo a ordenar
men1 db "El arreglo antes de ordenar: ", 0            ;mensaje 1
len1 equ $-men1                                       ;tamaño del mensaje 1
men2 db 0xA,"El arreglo despues de ser ordenado: ", 0 ;mensaje 2
len2 equ $-men2                                       ;tamaño del mensaje 2
salto db 0x20, 0                                      ;espacio de linea
espacio db 0xA                                        ;salto de linea

section .bss 
buffer resb 4       ;variable reservada buffer para guardar caracteres 
aux resb 4          ;variable reservada aux para que guarde los caracteres ya invertidos
len resd 4          ;variable reservada len para guardar el tamaño del arreglo

section .text
 global _start
 _start:
 mov eax, 4
 mov ebx, 1
 mov ecx, men1         ;"antes de ordenar"
 mov edx, len1
 int 0x80
 
 mov edi, arreglo       ;se mueve a edi la direccion del arreglo
 mov esi, buffer        ;se mueve la direccion del buffer para poder imprimir el arreglo
 mov ebx, 0             ;contador del arreglo para terminar la funcion conversion
 call conversion        ;esta funcion convierte e imprime el arreglo
 
 call bubble_sort       ;se llama la funcion bubble_sort
 
 mov eax, 4
 mov ebx, 1
 mov ecx, espacio        ;"salto de linea"
 mov edx, 1
 int 0x80

 mov eax, 4
 mov ebx, 1
 mov ecx, men2         ;"despues de ordenar"
 mov edx, len2
 int 0x80
 
 mov edi, arreglo       ;se mueve a edi la direccion del arreglo
 mov esi, buffer        ;se mueve la direccion del buffer para poder imprimir el arreglo
 mov ebx, 0             ;contador del arreglo para terminar la funcion conversion
 call conversion        ;se imprime de nuevo  

 mov eax, 4
 mov ebx, 1
 mov ecx, espacio        ;"salto de linea"
 mov edx, 1
 int 0x80
  
 jmp salida          
 
bubble_sort:
  mov ebx, 1
  cyclei:
  mov ebp, [len]  ;se mueve a ebp el tamaño del arreglo 
  cmp ebx, ebp
  jge regreso     ;si es mayor o igual al tamaño del arreglo ya termino de ordenar
  xor ecx, ecx    ;indice del arreglo j
  sub ebp, ebx    ;al tamaño del arreglo se le resta ebx
    cyclej:
    cmp ecx, ebp       ;si llega al ultimo elemento a contar entonces el mayor ya esta hasta el final
    jge next           ;salta a la siguiente etiqueta
     
    ;se compara los datos e ir intercambiando el mayor 
    mov al, [arreglo + ecx]
    cmp al, [arreglo + ecx + 1]
    jle siguiente

    ;se intercambia si es que al es mayor al siguiente dato
    push ebx
    mov bl, [arreglo + ecx + 1] 
    mov [arreglo + ecx],bl
    mov [arreglo + ecx + 1], al
    pop ebx
    jmp siguiente

siguiente:
 inc ecx      ;continua con el otro dato
 jmp cyclej   ;se repite para que compare el mayor con otro numeor e irlo arrastrando hasta el final

next:
 inc ebx
 jmp cyclei

conversion:
 mov ecx, 10            ;divisor 10 para convertirlos a caracteres
 mov al, [edi + ebx]    ;se mueve al registro de 16 bits el entero
 mov [len], ebx         ;se myeve a la variable len el tamaño del arreglo
 cmp ebx, 4             ;se compara ebx con el tamaño del arreglo
 jg regreso             ;si es mayor entonces ya imprimio todos y sale para arreglarlos
 enter 0, 0             ;se crea un espacio de memoria
 push ebx               ;se mueve al stack el contador del arreglo
 mov ebx, 0             ;se convierte en puntero para el buffer y conatador del digito
 change:                
  xor edx, edx          ;necesario para guardar los valores a convertirlos
  div ecx               ;edx = eax / 10
  add edx, '0'          ;se convierte el numero a caracter 
  mov [esi + ebx],dl    ;se mueve al buffer el caracter convertido, del registro de 8 bits
  inc ebx               ;incrementa ebx que es el puntero de buffer
  cmp eax, 0            ;se compara con 0 para que termine de convertir el numero y eax = 0
  jne change            ;bucle para que convierta todo el numero a ASCII
  dec ebx               ;se decrementa una unidad  
  call invertir         ;se invierte la cadena ya que al ser convertida de entero a ASCCI se muestra al reves
  pop ebx               ;se regresa el contador del arreglo
  leave                 ;se libera el espacio reservado en stack
  inc ebx               ;se incrementa para continuar con el otro dato
  inc eax               ;se incrementa ya que es el tamaño del digito
  mov ebp, eax          ;se mueve el valor de eax al registro ebp que es el contador del caracter
  call imprime          ;se imprime la cadena invertida

invertir:
 mov ecx, [esi + ebx]  ;movemos al registro ecx, la ultima letra de la cadena
 mov [aux + eax], ecx  ;movemos a la variable aux, el valor de ecx
 shr ecx, 1            ;dezplazamos un byte a la derecha en el registro ecx
 cmp ebx, 0            ;comparamos ebx con 0 ya que es el tamaño de la cadena
 jz regreso            ;si es igual a 0 es que ya recorrio toda la cadena y imprime la cadena inverida
 inc eax               ;incrementamos eax para movernos al otro lado del caracter
 dec ebx               ;decrementamos una unidad ebx para recorre el digito invertido
 jmp invertir          ;salta a la etiqueta invertir para continuar con el sig caracter

imprime:
 push ebx              ;se mueve al stack el contador del arreglo
 mov eax, 4
 mov ebx, 1
 mov ecx, aux
 mov edx, ebp
 int 0x80

 mov eax, 4
 mov ebx, 1
 mov ecx, salto
 mov edx, 1
 int 0x80
 pop ebx               ;se regresa el valor del contador a ebx

 jmp conversion        ;se regresa a la etiqueta conversion que seria el siguiente dato del arreglo

regreso:
 ret
 
salida:
 mov eax, 1
 mov ebx, 0
 mov ecx, 0 
 mov edx, 0 
 int 0x80