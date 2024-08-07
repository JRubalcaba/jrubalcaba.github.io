################################# PR�CTICA: Modelo Ectotermo #######################################
###################### T�cnicas de conservaci�n de la biodiversidad y Ecolog�a #####################

### Juanvi G. Rubalcaba: jg.rubalcaba@gmail.com 

######################## Funciones de transferencia de calor ########################

Q_absorcion_sol <- function(A, a, D, S) {A * a * (D + S)}  
# A: superficie expuesta, a: absorbancia de radiaci�n solar, D: radiaci�n directa, S: radiaci�n difusa

Q_emision_IR <- function(A, epsilon, boltzmann, Ta, Tb) {-A * epsilon * boltzmann * ((Tb+273)^4 - (Ta+273)^4)}
# epsilon: emisividad IR, bolzmann: constante Stefan-Botzmann; Tb: Temperatura corporal

Q_conveccion <- function(A, hc, Ta, Tb) {-A * hc * (Tb - Ta)}
# hc: coeficiente de convecci�n, Ta: temperatira del aire 

Q_neto <- function(Q_absorcion_sol, Q_emision_IR, Q_conveccion) {Q_absorcion_sol + Q_emision_IR + Q_conveccion}

######################## Par�metros del modelo ######################## 

## Morfolog�a animal

M = 5                  # Masa corporal (g)
A = 1e-4 * 10 * M^(2/3) # Superficie (m2) - Connor et al. 1999
l = A^(1/2)             # Longitud del cuerpo (m) - Mitchell et al. 1976
C = 3.7                 # Capacidad calor�fica media del cuerpo (J g-1 �C-1) - Porter et al. 1973

# Temperatura ambiental

Ta = 20    # Temperatura del aire (�C)
v = 0.8    # Velocidad del viento (m s-1)

# Radiaci�n solar

a = 0.9       # Absorbancia piel
D = 400       # Radiaci�n directa (W m-2)
s = D * 0.2   # Radiaci�n difusa (20%)

# Emision de IR

epsilon = 0.9       # Emisividad IR - Porter et al. 1973
boltzmann = 5.67e-8 # Constante Stefan-Botzmann (W m-2 �C-4)

# Coeficiente de conveccion (C�lculo emp�rico)

hc = 6.77 * v^0.6 * l^-0.4 # Coeficiente de conveccion (para reptiles, Spotila et al. 1992)

######################## C�lculo de Tb ######################## 

Tb = 10 # Partimos de una temperatura corporal inicial
Q_abs <- Q_absorcion_sol(A, a, D, s)  # Calculamos la energ�a absorbida de la radiaci�n solar
Q_IR <- Q_emision_IR(A, epsilon, boltzmann, Ta, Tb) # Calculamos la energ�a t�rmica emitida, dada la Tb actual
Q_conv <- Q_conveccion(A, hc, Ta, Tb) # Calculamos la transferencia (p�rdida o ganancia) de calor por convecci�n

Q_net <- Q_neto(Q_abs, Q_IR, Q_conv) # y el calor neto

# La temperatura en el instante siguiente (1 segundo m�s tarde) viene dada por:
Tb + 1 / (M * C) * Q_net 

######################## C�lculo iterativo de Tb ######################## 

t_total <- 30 * 60     # Tiempo total de exposici�n (segundos)
Tb <- numeric(t_total) # Vector (de longitud t_total) para almacenar los resultados
Tb[1] <- 10            # Indicamos la temperatura inicial en la primera entrada del vector

for(t in 2:t_total){ # Para cada entrada del vector (empezando por la segunda entrada)
  Q_abs <- Q_absorcion_sol(A, a, D, s)                 # calculamos el calor aborbido por radiaci�n solar
  Q_IR <- Q_emision_IR(A, epsilon, boltzmann, Ta, Tb[t-1]) # por radiaci�n t�rmica
  Q_conv <- Q_conveccion(A, hc, Ta, Tb[t-1])           # el calor transfrido por convecci�n
  
  Q_net <- Q_neto(Q_abs, Q_IR, Q_conv)                 # y el calor neto
  
  Tb[t] <- Tb[t-1] + 1 / (M * C) * Q_net               # Almacenamos el valor de temperatura en el vector
}

# Representaci�n gr�fica
plot(Tb, ylim = c(0,40), type = "l", ylab = "Temperatura corporal (�C)", xlab  ="Tiempo (s)", lwd = 2, col = "black")
abline(h = Ta, lty = 3) # a�adimos una l�nea horizontal con la temperatura del aire

######################## Simulando diferentes microambientes ######################## 

# Aqu� simularemos a un lagarto con capacidad para regular la temperatura corporal
# movi�ndose entre dos microambientes (sol y sombra)

# Radiaci�n solar (ambiente expuesto)

D_sol = 400       # Radiaci�n directa (W m-2)
s_sol = D_sol * 0.2   # Radiaci�n difusa (20%)

# Radiaci�n solar (a la sombra)

porcentaje_sombra = 0.8 # proporci�n de radiaci�n bloqueada
D_sombra = D_sol * (1 - porcentaje_sombra)

# L�mites de temperatura voluntarios 

Tmax = 32 # l�mite superior (�C) - Si excede este l�mite el animal debe moverse a la sombra
Tmin = 26 # l�mite inferior (�C) - Por debajo de Tmin, el animal tiene que ponerse al sol
# Entre Tmin y Tmax el animal puede dedicase a forrajear

# NOTA: vuelve a poner
M = 5
a = 0.9

t_total <- 60 * 60     # tiempo de simulaci�n (segundos)
Tb <- numeric(t_total) # vector de temperaturas
Tb[1] <- 10            # temperatura inicial
microambiente <- numeric(t_total) # ahora tambi�n almacenamos informaci�n sobre qu� microambiente (sol/sombra) elige el animal 
microambiente[1] <- "sol"         # seleccionamos un microambiente inicial

for(t in 2:t_total){
  # Calculamos la temperatura en el microambiente donde est� el lagarto
  if(microambiente[t-1] == "sol"){
    Q_abs <- Q_absorcion_sol(A, a, D_sol, s) # En esta simulaci�n s�lo Qabs cambia entre sol y sombra, el resto se mantienen
    Q_IR <- Q_emision_IR(A, epsilon, boltzmann, Ta, Tb[t-1]) 
    Q_conv <- Q_conveccion(A, hc, Ta, Tb[t-1])
  }
  if(microambiente[t-1] == "sombra"){
    Q_abs <- Q_absorcion_sol(A, a, D_sombra, s)
    Q_IR <- Q_emision_IR(A, epsilon, boltzmann, Ta, Tb[t-1]) 
    Q_conv <- Q_conveccion(A, hc, Ta, Tb[t-1])
  }
  # Calculamos el calor total y la temperatura
  Q_net <- Q_neto(Q_abs, Q_IR, Q_conv)
  Tb[t] <- Tb[t-1] + 1 / (M * C) * Q_net 
  
  # Seg�n su temperatura corporal, el animal va a escoger un nuevo microambiente
  if(Tb[t] > Tmax){ # Si la tempertura corporal (Tb) excede el l�mite superior (Tmax), se mueve a la sombra
    microambiente[t] <- "sombra"
  }
  if(Tb[t] < Tmin){ # Si Tb est� por debajo del l�mite inferior, va al sol
    microambiente[t] <- "sol"
  }
  if(Tb[t] > Tmin && Tb[t] < Tmax){ # Si Tb est� dentro de los l�mites, se queda donde est�
    microambiente[t] <- microambiente[t-1]
  }
}

# Representaci�n gr�fica de Tb

plot(Tb, ylim = c(0,45), type = "l", ylab = "Temperatura corporal (�C)", xlab  ="Tiempo (s)", lwd = 2, col = "black")
abline(h = Tmax, lty = 3, col="red")  # L�mite superior (Tmax)
abline(h = Tmin, lty = 3, col="blue") # L�mite inferior (Tmin)

# Tambi�n podemos mirar el vector de microambientes

microambiente

######################## Datos microclim�ticos reales ########################

# Cargamos datos de tempertura y radiaci�n solar al sol y a la sombra (50% de radiaci�n)
# localizaci�n: Manzanares el Real (Madrid) long=-3.7864900, lat=40.7513200
# Datos promedio de 20 a�os para un d�a de abril

# Estos datos han sido generados con el paquete NicheMapR (Kearney and Porter 2017 Ecography) 

dir <- "..." # Introduce el directorio donde tienes el archivo "data_temp.csv"
data_temp <- read.csv(paste0(dir,"/data_temp.csv"))

head(data_temp) # Ta_sol / Ta_sombra (temperatura del aire sol / sombra, �C) - Rad_sol / Rad_sombra (radiaci�n solar, Wm-2)

plot(data_temp$Ta_sol, type="l", ylab="Temperatura del aire (�C)", xlab="tiempo")
lines(data_temp$Ta_sombra, lty=3) # Temperatura al sol (linea continua) y a la sombra (l�nea punteada)

plot(data_temp$Rad_sol, type="l", ylab="Radiaci�n solar (Wm2)", xlab="tiempo")
lines(data_temp$Rad_sombra, lty=3) # Radiaci�n solar al sol (linea continua) y a la sombra (l�nea punteada)

## Simulaci�n: 

t_total <- 60*60*24    # tiempo de simulaci�n (24 horas)
Tb <- numeric(t_total) # vector de temperaturas
Tb[1] <- data_temp$Ta_sol[1] 
microambiente <- numeric(t_total) # vector de microambientes
microambiente[1] <- "sol"
for(t in 2:t_total){
  # Calculamos la temperatura en el microambiente donde est� el lagarto
  if(microambiente[t-1] == "sol"){
    Q_abs <- Q_absorcion_sol(A, a, data_temp$Rad_sol[t-1], 0) 
    Q_IR <- Q_emision_IR(A, epsilon, boltzmann, data_temp$Ta_sol[t-1], Tb[t-1]) 
    Q_conv <- Q_conveccion(A, hc, data_temp$Ta_sol[t-1], Tb[t-1])
  }
  if(microambiente[t-1] == "sombra"){
    Q_abs <- Q_absorcion_sol(A, a, data_temp$Rad_sombra[t-1], 0)
    Q_IR <- Q_emision_IR(A, epsilon, boltzmann, data_temp$Ta_sol[t-1], Tb[t-1]) 
    Q_conv <- Q_conveccion(A, hc, data_temp$Ta_sombra[t-1], Tb[t-1])
  }
  # Calculamos el calor total y la temperatura
  Q_net <- Q_neto(Q_abs, Q_IR, Q_conv)
  Tb[t] <- Tb[t-1] + 1 / (M * C) * Q_net 
  
  # Selecci�n de microambientes
  if(Tb[t] > Tmax){ 
    microambiente[t] <- "sombra"
  }
  if(Tb[t] < Tmin){ 
    microambiente[t] <- "sol"
  }
  if(Tb[t] > Tmin && Tb[t] < Tmax){ 
    microambiente[t] <- microambiente[t-1]
  }
}

# Representaci�n gr�fica de Tb 

plot(Tb, type="l", ylim=c(0, 35))
abline(h=Tmax, lty=3, col="red") # L�mite superior (Tmax)
abline(h=Tmin, lty=3, col="blue") # L�mite inferior (Tmin)

## Qu� indicadores ecol�gicos podemos extraer de la simulaci�n? ##

# Cu�l es la temperatura corporal media a lo largo del d�a?

mean(Tb)

# Excede la temperatura m�xima (Tmax) en alg�n momento?

max(Tb)

# El animal s�lo est� activo cuando su temperatura est� entre Tmin y Tmax, cu�nto tiempo a lo largo del d�a logra estar en este rango?

length(which(Tb > Tmin & Tb < Tmax)) / length(Tb) * 100 # Porcentaje de tiempo entre Tmin y Tmax

# El animal busca alimento en ambientes expuestos (fuera del refugio), cu�nto tiempo puede estar en ambientes expuestos?

length(which(microambiente =="sol")) / length(Tb) * 100 # Porcentaje de tiempo al sol

# Finalmente, el animal s�lo puede forrajear si est� activo (i.e., entre Tmin - Tmax) y adem�s est� en ambientes expuestos (i.e., al sol):

length(which(Tb > Tmin & Tb < Tmax & microambiente =="sol")) / length(Tb) # Porcentaje de tiempo real disponible para el forrajeo

# Ahora vamos a extraer  estos indicadores para cada hora del d�a utilizando la funci�n "tapply(vector, categor�a, funci�n)"
# "tapply" aplica la funci�n que nosotros le indiquemos (e.g. media) para cada cateogr�a (e.g. hora del d�a) 
# del vector que le digamos (e.g. el vector de temperaturas corporales por minuto, Tb)

# Cu�l es la temperatura corporal media por hora?

Tb_media <- tapply(Tb, data_temp$hora, function(x) mean(x))

barplot(Tb_media, xlab="hora", ylab="Temperatura corporal (�C)")

# Cu�nto tiempo est� activo, i.e. qu� porcentaje de tiempo (por hora) pasa Tb entre Tmin y Tmax

tiempo_forrajeo <- tapply(Tb, data_temp$hora, function(x){length(which(x > Tmin & x < Tmax))/length(x)})

barplot(100 * tiempo_forrajeo, xlab="hora", ylab="Tiempo entre Tmin y Tmax (%)")

# Cu�nto tiempo pasa en microambientes expuestos?

tiempo_sol <- tapply(microambiente, data_temp$hora, function(x){length(which(x == "sol"))/length(x)})

barplot(100 * tiempo_sol, xlab="hora", ylab="Tiempo al sol (%)")

# Cu�l es el porcentaje de tiempo real para el forrajeo (i.e., el animal est� activo + en ambientes expuestos)

barplot(100 * tiempo_sol * tiempo_forrajeo, xlab="hora", ylab="Tiempo para alimentarse (%)", add=T, col="orange")

mean(tiempo_sol * tiempo_forrajeo) * 100

######################## PROYECTANDO EL NICHO FUNDAMENTAL ########################

require(raster)
require(ggplot2)

## Par�metros del animal

M = 5                  # Masa corporal (g)
A = 1e-4 * 10 * M^(2/3) # Superficie (m2)
l = A^(1/2)             # Longitud del cuerpo (m)
C = 3.7                 # Capacidad calor�fica media del cuerpo (J g-1 �C-1)
a = 0.9       # Absorbancia piel
v = 0.8    # Velocidad del viento (m s-1)
hc = 6.77 * v^0.6 * l^-0.4 # Coeficiente de conveccion (para reptiles, Spotila et al. 1992)
Tmax = 32 # l�mite t�rmico superior (�C) 
Tmin = 26 # l�mite t�rmico inferior (�C) 

## Simulaci�n 

load(paste0(dir, "/microclimate_data.Rdata")) # Abrimos los datos microclim�ticos del Pale�rtico oeste 
load(paste0(dir, "/xy.values.Rdata")) # Lista de coordenadas

str(microclimate_data) # Lista de 1008 matrices, cada matriz contiene los datos microclim�ticos (por minuto) de cada celda en el Pale�rtico oeste
str(xy.values) # Lista de coordenadas (Longitud, Latitud) de las matrices

Tb_paleartico <- microambiente_paleartico <- array(NA, dim=c(60*60*24,nrow(xy.values)))
for(i in 1:nrow(xy.values)){
  
  # Datos microclim�ticos en la celda "i"
  
  data_temp <- microclimate_data[[i]]
  
  # Simulaci�n (Tb y selecci�n de microambientes) en celda "i"
  
  t_total <- 60*60*24    # tiempo de simulaci�n (24 horas)
  Tb <- numeric(t_total) # vector de temperaturas
  Tb[1] <- data_temp$Ta_sol[1] 
  microambiente <- numeric(t_total) # vector de microambientes
  microambiente[1] <- "sol"
  for(t in 2:t_total){
    # Calculamos la temperatura en el microambiente donde est� el lagarto
    if(microambiente[t-1] == "sol"){
      Q_abs <- Q_absorcion_sol(A, a, data_temp$Rad_sol[t-1], 0) 
      Q_IR <- Q_emision_IR(A, epsilon, boltzmann, data_temp$Ta_sol[t-1], Tb[t-1]) 
      Q_conv <- Q_conveccion(A, hc, data_temp$Ta_sol[t-1], Tb[t-1])
    }
    if(microambiente[t-1] == "sombra"){
      Q_abs <- Q_absorcion_sol(A, a, data_temp$Rad_sombra[t-1], 0)
      Q_IR <- Q_emision_IR(A, epsilon, boltzmann, data_temp$Ta_sol[t-1], Tb[t-1]) 
      Q_conv <- Q_conveccion(A, hc, data_temp$Ta_sombra[t-1], Tb[t-1])
    }
    # Calculamos el calor total y la temperatura
    Q_net <- Q_neto(Q_abs, Q_IR, Q_conv)
    Tb[t] <- Tb[t-1] + 1 / (M * C) * Q_net 
    
    # Selecci�n de microambientes
    if(Tb[t] > Tmax){ 
      microambiente[t] <- "sombra"
    }
    if(Tb[t] < Tmin){ 
      microambiente[t] <- "sol"
    }
    if(Tb[t] > Tmin && Tb[t] < Tmax){ 
      microambiente[t] <- microambiente[t-1]
    }
  }
  
  Tb_paleartico[,i] <- Tb
  microambiente_paleartico[,i] <- microambiente
  
  print(paste(round(i / nrow(xy.values) * 100, 2), "%"))
  
}

load(file=paste0(dir,"/Tb_paleartico_5g.RData"))
load(file=paste0(dir,"/microambiente_paleartico_5g.RData"))

# Temperatura m�xima

max_Tb <- apply(Tb_paleartico, 2, max)

ggplot() + geom_tile(mapping = aes(x=xy.values[,1], y=xy.values[,2], fill=max_Tb)) +
  theme_classic() + theme(legend.title = element_blank(),
                          legend.position = "bottom",
                          axis.title = element_blank(),
                          axis.line = element_blank(),
                          axis.ticks = element_blank(),
                          axis.text = element_blank()) 

# Porcentaje de tiempo en el �ptimo, i.e. Tmin < Tb < Tmax

tiempo_Topt <- apply(Tb_paleartico, 2, function(x){
  length(which(x > Tmin & x < Tmax)) / length(x)
})

ggplot() + geom_tile(mapping = aes(x=xy.values[,1], y=xy.values[,2], fill=tiempo_Topt)) +
  theme_classic() + theme(legend.title = element_blank(),
                          legend.position = "bottom",
                          axis.title = element_blank(),
                          axis.line = element_blank(),
                          axis.ticks = element_blank(),
                          axis.text = element_blank()) 

# Tiempo expuesto al sol

tiempo_sol <- apply(microambiente_paleartico, 2, function(x){
  length(which(x == "sol")) / length(x)
})

ggplot() + geom_tile(mapping = aes(x=xy.values[,1], y=xy.values[,2], fill=tiempo_sol)) +
  theme_classic() + theme(legend.title = element_blank(),
                          legend.position = "bottom",
                          axis.title = element_blank(),
                          axis.line = element_blank(),
                          axis.ticks = element_blank(),
                          axis.text = element_blank()) 






