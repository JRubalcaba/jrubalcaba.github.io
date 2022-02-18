################################# PRÁCTICA: Modelo Ectotermo #######################################
###################### Técnicas de conservación de la biodiversidad y Ecología #####################

### Juanvi G. Rubalcaba: jg.rubalcaba@gmail.com 

######################## Funciones de transferencia de calor ########################

Q_absorcion_sol <- function(A, a, D, S) {A * a * (D + S)}  
# A: superficie expuesta, a: absorbancia de radiación solar, D: radiación directa, S: radiación difusa

Q_emision_IR <- function(A, epsilon, boltzmann, Ta, Tb) {-A * epsilon * boltzmann * ((Tb+273)^4 - (Ta+273)^4)}
# epsilon: emisividad IR, bolzmann: constante Stefan-Botzmann; Tb: Temperatura corporal

Q_conveccion <- function(A, hc, Ta, Tb) {-A * hc * (Tb - Ta)}
# hc: coeficiente de convección, Ta: temperatira del aire 

Q_neto <- function(Q_absorcion_sol, Q_emision_IR, Q_conveccion) {Q_absorcion_sol + Q_emision_IR + Q_conveccion}

######################## Parámetros del modelo ######################## 

## Morfología animal

M = 5                  # Masa corporal (g)
A = 1e-4 * 10 * M^(2/3) # Superficie (m2) - Connor et al. 1999
l = A^(1/2)             # Longitud del cuerpo (m) - Mitchell et al. 1976
C = 3.7                 # Capacidad calorífica media del cuerpo (J g-1 ºC-1) - Porter et al. 1973

# Temperatura ambiental

Ta = 20    # Temperatura del aire (ºC)
v = 0.8    # Velocidad del viento (m s-1)

# Radiación solar

a = 0.9       # Absorbancia piel
D = 400       # Radiación directa (W m-2)
s = D * 0.2   # Radiación difusa (20%)

# Emision de IR

epsilon = 0.9       # Emisividad IR - Porter et al. 1973
boltzmann = 5.67e-8 # Constante Stefan-Botzmann (W m-2 ºC-4)

# Coeficiente de conveccion (Cálculo empírico)

hc = 6.77 * v^0.6 * l^-0.4 # Coeficiente de conveccion (para reptiles, Spotila et al. 1992)

######################## Cálculo de Tb ######################## 

Tb = 10 # Partimos de una temperatura corporal inicial
Q_abs <- Q_absorcion_sol(A, a, D, s)  # Calculamos la energía absorbida de la radiación solar
Q_IR <- Q_emision_IR(A, epsilon, boltzmann, Ta, Tb) # Calculamos la energía térmica emitida, dada la Tb actual
Q_conv <- Q_conveccion(A, hc, Ta, Tb) # Calculamos la transferencia (pérdida o ganancia) de calor por convección

Q_net <- Q_neto(Q_abs, Q_IR, Q_conv) # y el calor neto

# La temperatura en el instante siguiente (1 segundo más tarde) viene dada por:
Tb + 1 / (M * C) * Q_net 

######################## Cálculo iterativo de Tb ######################## 

t_total <- 30 * 60     # Tiempo total de exposición (segundos)
Tb <- numeric(t_total) # Vector (de longitud t_total) para almacenar los resultados
Tb[1] <- 10            # Indicamos la temperatura inicial en la primera entrada del vector

for(t in 2:t_total){ # Para cada entrada del vector (empezando por la segunda entrada)
  Q_abs <- Q_absorcion_sol(A, a, D, s)                 # calculamos el calor aborbido por radiación solar
  Q_IR <- Q_emision_IR(A, epsilon, boltzmann, Ta, Tb[t-1]) # por radiación térmica
  Q_conv <- Q_conveccion(A, hc, Ta, Tb[t-1])           # el calor transfrido por convección
  
  Q_net <- Q_neto(Q_abs, Q_IR, Q_conv)                 # y el calor neto
  
  Tb[t] <- Tb[t-1] + 1 / (M * C) * Q_net               # Almacenamos el valor de temperatura en el vector
}

# Representación gráfica
plot(Tb, ylim = c(0,40), type = "l", ylab = "Temperatura corporal (ºC)", xlab  ="Tiempo (s)", lwd = 2, col = "black")
abline(h = Ta, lty = 3) # añadimos una línea horizontal con la temperatura del aire

######################## Simulando diferentes microambientes ######################## 

# Aquí simularemos a un lagarto con capacidad para regular la temperatura corporal
# moviéndose entre dos microambientes (sol y sombra)

# Radiación solar (ambiente expuesto)

D_sol = 400       # Radiación directa (W m-2)
s_sol = D_sol * 0.2   # Radiación difusa (20%)

# Radiación solar (a la sombra)

porcentaje_sombra = 0.8 # proporción de radiación bloqueada
D_sombra = D_sol * (1 - porcentaje_sombra)

# Límites de temperatura voluntarios 

Tmax = 32 # límite superior (ºC) - Si excede este límite el animal debe moverse a la sombra
Tmin = 26 # límite inferior (ºC) - Por debajo de Tmin, el animal tiene que ponerse al sol
# Entre Tmin y Tmax el animal puede dedicase a forrajear

# NOTA: vuelve a poner
M = 5
a = 0.9

t_total <- 60 * 60     # tiempo de simulación (segundos)
Tb <- numeric(t_total) # vector de temperaturas
Tb[1] <- 10            # temperatura inicial
microambiente <- numeric(t_total) # ahora también almacenamos información sobre qué microambiente (sol/sombra) elige el animal 
microambiente[1] <- "sol"         # seleccionamos un microambiente inicial

for(t in 2:t_total){
  # Calculamos la temperatura en el microambiente donde está el lagarto
  if(microambiente[t-1] == "sol"){
    Q_abs <- Q_absorcion_sol(A, a, D_sol, s) # En esta simulación sólo Qabs cambia entre sol y sombra, el resto se mantienen
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
  
  # Según su temperatura corporal, el animal va a escoger un nuevo microambiente
  if(Tb[t] > Tmax){ # Si la tempertura corporal (Tb) excede el límite superior (Tmax), se mueve a la sombra
    microambiente[t] <- "sombra"
  }
  if(Tb[t] < Tmin){ # Si Tb está por debajo del límite inferior, va al sol
    microambiente[t] <- "sol"
  }
  if(Tb[t] > Tmin && Tb[t] < Tmax){ # Si Tb está dentro de los límites, se queda donde está
    microambiente[t] <- microambiente[t-1]
  }
}

# Representación gráfica de Tb

plot(Tb, ylim = c(0,45), type = "l", ylab = "Temperatura corporal (ºC)", xlab  ="Tiempo (s)", lwd = 2, col = "black")
abline(h = Tmax, lty = 3, col="red")  # Límite superior (Tmax)
abline(h = Tmin, lty = 3, col="blue") # Límite inferior (Tmin)

# También podemos mirar el vector de microambientes

microambiente

######################## Datos microclimáticos reales ########################

# Cargamos datos de tempertura y radiación solar al sol y a la sombra (50% de radiación)
# localización: Manzanares el Real (Madrid) long=-3.7864900, lat=40.7513200
# Datos promedio de 20 años para un día de abril

# Estos datos han sido generados con el paquete NicheMapR (Kearney and Porter 2017 Ecography) 

dir <- "..." # Introduce el directorio donde tienes el archivo "data_temp.csv"
data_temp <- read.csv(paste0(dir,"/data_temp.csv"))

head(data_temp) # Ta_sol / Ta_sombra (temperatura del aire sol / sombra, ºC) - Rad_sol / Rad_sombra (radiación solar, Wm-2)

plot(data_temp$Ta_sol, type="l", ylab="Temperatura del aire (ºC)", xlab="tiempo")
lines(data_temp$Ta_sombra, lty=3) # Temperatura al sol (linea continua) y a la sombra (línea punteada)

plot(data_temp$Rad_sol, type="l", ylab="Radiación solar (Wm2)", xlab="tiempo")
lines(data_temp$Rad_sombra, lty=3) # Radiación solar al sol (linea continua) y a la sombra (línea punteada)

## Simulación: 

t_total <- 60*60*24    # tiempo de simulación (24 horas)
Tb <- numeric(t_total) # vector de temperaturas
Tb[1] <- data_temp$Ta_sol[1] 
microambiente <- numeric(t_total) # vector de microambientes
microambiente[1] <- "sol"
for(t in 2:t_total){
  # Calculamos la temperatura en el microambiente donde está el lagarto
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
  
  # Selección de microambientes
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

# Representación gráfica de Tb 

plot(Tb, type="l", ylim=c(0, 35))
abline(h=Tmax, lty=3, col="red") # Límite superior (Tmax)
abline(h=Tmin, lty=3, col="blue") # Límite inferior (Tmin)

## Qué indicadores ecológicos podemos extraer de la simulación? ##

# Cuál es la temperatura corporal media a lo largo del día?

mean(Tb)

# Excede la temperatura máxima (Tmax) en algún momento?

max(Tb)

# El animal sólo está activo cuando su temperatura está entre Tmin y Tmax, cuánto tiempo a lo largo del día logra estar en este rango?

length(which(Tb > Tmin & Tb < Tmax)) / length(Tb) * 100 # Porcentaje de tiempo entre Tmin y Tmax

# El animal busca alimento en ambientes expuestos (fuera del refugio), cuánto tiempo puede estar en ambientes expuestos?

length(which(microambiente =="sol")) / length(Tb) * 100 # Porcentaje de tiempo al sol

# Finalmente, el animal sólo puede forrajear si está activo (i.e., entre Tmin - Tmax) y además está en ambientes expuestos (i.e., al sol):

length(which(Tb > Tmin & Tb < Tmax & microambiente =="sol")) / length(Tb) # Porcentaje de tiempo real disponible para el forrajeo

# Ahora vamos a extraer  estos indicadores para cada hora del día utilizando la función "tapply(vector, categoría, función)"
# "tapply" aplica la función que nosotros le indiquemos (e.g. media) para cada cateogría (e.g. hora del día) 
# del vector que le digamos (e.g. el vector de temperaturas corporales por minuto, Tb)

# Cuál es la temperatura corporal media por hora?

Tb_media <- tapply(Tb, data_temp$hora, function(x) mean(x))

barplot(Tb_media, xlab="hora", ylab="Temperatura corporal (ºC)")

# Cuánto tiempo está activo, i.e. qué porcentaje de tiempo (por hora) pasa Tb entre Tmin y Tmax

tiempo_forrajeo <- tapply(Tb, data_temp$hora, function(x){length(which(x > Tmin & x < Tmax))/length(x)})

barplot(100 * tiempo_forrajeo, xlab="hora", ylab="Tiempo entre Tmin y Tmax (%)")

# Cuánto tiempo pasa en microambientes expuestos?

tiempo_sol <- tapply(microambiente, data_temp$hora, function(x){length(which(x == "sol"))/length(x)})

barplot(100 * tiempo_sol, xlab="hora", ylab="Tiempo al sol (%)")

# Cuál es el porcentaje de tiempo real para el forrajeo (i.e., el animal está activo + en ambientes expuestos)

barplot(100 * tiempo_sol * tiempo_forrajeo, xlab="hora", ylab="Tiempo para alimentarse (%)", add=T, col="orange")

mean(tiempo_sol * tiempo_forrajeo) * 100

######################## PROYECTANDO EL NICHO FUNDAMENTAL ########################

require(raster)
require(ggplot2)

## Parámetros del animal

M = 5                  # Masa corporal (g)
A = 1e-4 * 10 * M^(2/3) # Superficie (m2)
l = A^(1/2)             # Longitud del cuerpo (m)
C = 3.7                 # Capacidad calorífica media del cuerpo (J g-1 ºC-1)
a = 0.9       # Absorbancia piel
v = 0.8    # Velocidad del viento (m s-1)
hc = 6.77 * v^0.6 * l^-0.4 # Coeficiente de conveccion (para reptiles, Spotila et al. 1992)
Tmax = 32 # límite térmico superior (ºC) 
Tmin = 26 # límite térmico inferior (ºC) 

## Simulación 

load(paste0(dir, "/microclimate_data.Rdata")) # Abrimos los datos microclimáticos del Paleártico oeste 
load(paste0(dir, "/xy.values.Rdata")) # Lista de coordenadas

str(microclimate_data) # Lista de 1008 matrices, cada matriz contiene los datos microclimáticos (por minuto) de cada celda en el Paleártico oeste
str(xy.values) # Lista de coordenadas (Longitud, Latitud) de las matrices

Tb_paleartico <- microambiente_paleartico <- array(NA, dim=c(60*60*24,nrow(xy.values)))
for(i in 1:nrow(xy.values)){
  
  # Datos microclimáticos en la celda "i"
  
  data_temp <- microclimate_data[[i]]
  
  # Simulación (Tb y selección de microambientes) en celda "i"
  
  t_total <- 60*60*24    # tiempo de simulación (24 horas)
  Tb <- numeric(t_total) # vector de temperaturas
  Tb[1] <- data_temp$Ta_sol[1] 
  microambiente <- numeric(t_total) # vector de microambientes
  microambiente[1] <- "sol"
  for(t in 2:t_total){
    # Calculamos la temperatura en el microambiente donde está el lagarto
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
    
    # Selección de microambientes
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

# Temperatura máxima

max_Tb <- apply(Tb_paleartico, 2, max)

ggplot() + geom_tile(mapping = aes(x=xy.values[,1], y=xy.values[,2], fill=max_Tb)) +
  theme_classic() + theme(legend.title = element_blank(),
                          legend.position = "bottom",
                          axis.title = element_blank(),
                          axis.line = element_blank(),
                          axis.ticks = element_blank(),
                          axis.text = element_blank()) 

# Porcentaje de tiempo en el óptimo, i.e. Tmin < Tb < Tmax

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






