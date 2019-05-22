---
title: "Cosas que conviene saber al usar AIC, DIC y otros criterios de información"
layout: article
---
Una de las herramientas estadísticas que más se usan en ecología son los indicadores de información (AIC, BIC, DIC y muchos otros). Aunque muchas veces los usamos como simples herramientas, hay una lógica muy potente e interesante detrás. Entender algo de esa lógica nos puede ayudar bastante. La idea de esta entrada es pensar un poco qué son los criterios de informaicón, de dónde vienen y cómo se interpretan. 

La idea general es... Cómo obtenemos una medida de la calidad de los modelos estadísticos que nos hable a la vez de "qué tan bueno es prediciendo" y "cómo de complejo es". Generalmente, cuanto más complejo es un modelo (porque tiene muchas variables, interacciones, etc) mejor describirá el proceso que estamos analizando, pero si es demasiado complejo perderá generalidad (será muy buebo prediciendo los datos para los que está entrenado, pero nada más). Asique tenemos un compromiso: queremos un modelo lo suficientemente complejo para que sea una buena descripción de nuestro sistema de estudio, pero no tan complejo como para que sólo pueda describir eso y no tenga validez general.  

Pues esto es lo que hacen los indicadores de información (medir el balance entre capacidad predictiva y complejidad) y por eso tienen siempre esta forma:

```tex
xIC = complejidad - bondad de ajuste
```

Donde xIC puede ser AIC (Aikaike Information Criterion), BIC (Bayesian Information Criterion), DIC (Deviance Information Criterion) y muchos otros, aquí sólo vamos a hablar de esos tres. Los dos primeros utilizan Maximum Likelihood como criterio de bondad de ajuste y el número de parámetros como medida de complejidad. El DIC es más complejo, trabaja con la distribución a posteriori de los parámetros, y mide la complejidad como el número y grado de interrelación entre los parámetros.

### Criterio de Información de Akaike

Algo que en ecología usamos constantemente:
$$$
\begin{align}
\ AIC = 2k -  2 \ln(L) \\
\end{align}
$$$
Donde k es el número de parámetros y L el máximo de la función de verosimilitud (Maximum likelihood). Según AIC, la bondad de ajuste es el valor de Maximum Likelihood y la complejidad es el número de parámetros. 

La medida de **bondad de ajuste** aquí es 2 ln(L). No vamos a entrar en detalles sobre qué es L (la versimilitud o likelihood), sólo un par de nociones. Primero, L es el producto de las probabilidades de cada dato condicionado al modelo, por lo que L se obtiene multiplicando n valores entre 0 y 1 (o sumando sus logaritmos). Segundo, ln(L) es una función creciente, pero la hacemos decrecer al multiplicarle -1. Así, cuando L tiende a infinito, la expresión -2 ln(L) tiende a un valor muy pequeño (AIC decrece cuando aumenta la bondad de ajuste). Una última nota es que L depende tanto de la distancia de cada dato al modelo (el likelihood) como del número de datos, n.

La **complejidad** en el AIC viene dada por k, que es el número de parámetros del modelo. La penalización de 2k del AIC es equivalente a hacer la validación cruzada del modelo dejando un dato fuera (leave one out-cross validation). ¿Qué ocurre si aumentamos el número de parámetros, k, y eso no se traduce en un incremento de la verosimilitud, L? Me explico mejor, qué pasa si hacemos más complicado el modelo sin que con ello consigamos que explique mejor nuestros datos. Lo que ocurre es que AIC aumentará del orden de 2 ∆k. Por tanto, diferencias de AIC de aproximadamente 2 entre modelos que difieren en un solo parámetro indican que la verosimilitud del modelo no cambia a pesar de que añadamos o quitemos un parámetro. Si lo que estamos haciendo es quitar parámetros para simplificar el modelo, podemos establecer como criterio dejar de quitar variables cuando el decremento de AIC < 2, lo que indica cambios no significativos en la bondad de ajuste del modelo.

Como veremos, AIC tiene una forma menos restrictiva que otros indicadores de medir la complejidad del modelo: sumando al indicador un número entero k que corresponde al número de parámetros. El problema de utilizar k como única medida de complejidad es que su efecto es minúsculo comparado con el valor que toma -2ln(L) que depende del número de datos n (L es proporcional a n). En otras palabras, perdonamos que el modelo sea muy complejo siempre y cuando tenga muchos datos para avalar cada parámetro. Esto se debe a que el AIC tiene como objetivo seleccionar el modelo que mejor hace predicciones dentro de los datos que lo han generado. Es decir, deja en el aire la cuestión de que un modelo complejo es también muy poco general, a pesar de que haya muchos datos avalándolo, y se centra en encontrar el modelo que hace mejores predicciones a pequeña escala. Tenemos que conseguir, por lo tanto, que aunque L dependa de n, esto no compense el exceso de complejidad del modelo.

### Criterio de Información Bayesiano

Muy similar al AIC es el criterio bayesiano de información, BIC (Bayesian Information Criterion) de Schwarz, que viene dado por:
$$$
\begin{align}
\ BIC = k \ln(n) -  2 \ln(L) \\
\end{align}
$$$

Donde, de nuevo k es el número de parámetros, L es el valor de máxima verosimilitud y n es el número de datos. Igual que el AIC se basa en la máxima verosimilitud como método de medida de la bondad de ajuste. Aquí vemos que la medida de la complejidad incorpora tanto k como ln(n). Esto independiza al indicador del tamaño muestral y hace que penalice más la complejidad que el AIC.

El resultado es que el BIC generalmente selecciona el modelo más abstracto, más sencillo y que hace predicciones a menor detalle, mientras que el AIC dará con un modelo más complejo y pragmático que hace predicciones con mayor detalle pero dentro de nuestros propios datos.

A pesar de ello, tanto AIC como BIC incurren en una excesiva simplificación del significado de complejidad del modelo. Recordemos que ambos miden la complejidad a partir del número de parámetros, k. Uno de los problemas de utilizar ese criterio de penalización es que require asumir que los parámetros son independientes entre ellos. Esto sólo es cierto si la colinealidad entre las variables del modelo es cero y además cada variable contribuye del mismo modo al modelo, lo cual no es cierto si se trata de modelos jerárquicos, donde la varianza está compartimentada por factores aleatorios.

Otra cuestión importante de medir la complejidad con el número de parámetros es que se ignora la incertidumbre en el modelo. Es decir, con AIC y BIC, el modelo se ha generado eligiendo el conjunto de valores de los parámetros que maximizan la verosimilitud, esto es, existe un valor puntual para cada parámetro. Los parámetros pueden no entenderse como valores puntuales sino como funciones de distribución que dependen de la dispersión de los datos o incertidumbre del modelo.


### Criterio de Información de la Devianza

El DIC (Deviance Information Criterion) de Spiegelhalter es una versión generalizada del AIC y del BIC que incorpora la batería de procedimientos y la lógica de la estadística bayesiana. El DIC utiliza cadenas de Monte Carlo para buscar la distribución de los parámetros. Es decir, no se buscan los valores puntuales de los parámetros que maximizan la función de verosimilitud, sino que se trabaja con la función completa de verosimilitud. Así, recordamos que la verosimilitud es la probabilidad condicionada de los datos al modelo, p(y|θk), y que AIC y BIC miden la bondad de ajuste como la altura del punto de máxima verosimilitud, L. Por su parte, el DIC extrae la devianza, -2, la cual tiene en cuenta la función completa de versomilitud. La medida de bondad de ajuste es el promedio de la devianza:
$$$
\begin{align}
\ \bar{D}(\theta) = -2 \int \log(p(y|\theta)) \, d\theta\\
\end{align}
$$$
Para medir la complejidad del modelo, el DIC utiliza de nuevo la devianza de las funciones de los parámetros. Así, cuando los parámetros de un modelo están correlacionados, la búsqueda con MCMC genera distribuciones con alta devianza. Esto es, si los parámetros covarían habrá mayor variabilidad en el espacio de parámetros. Para penalizar la complejidad, el DIC calcula el número efectivo de parámetros, pD, que se define como el promedio de la devianza menos la devianza evaluada en el promedio de los parámetros:
$$$
\begin{align}
\ p_D = \bar{D} - D(\bar{\theta})\\
\end{align}
$$$
Con ello, el DIC se define como:
$$$
\begin{align}
\ DIC = \bar{D}(\theta) + p_D = D(\bar{\theta}) + 2 p_D\\
\end{align}
$$$
El número efectivo de parámetros tiene en cuenta simultáneamente el tamaño muestral, la relación (covariación) entre los parámetros, el número de parámetros y el tamaño de los efectos de las variables.

Por supuesto el DIC no está exento de críticas. En concreto, el sistema por el que penaliza el número de parámetros no equivale a una forma de cross-validation como ocurre en el AIC, lo que lleva a seleccionar modelos sobre-parametrizados. La forma de corregir esto es multiplicar por un factor el número efectivo de parámetros, tal que el indicador converja al método de leave one out al igual que el AIC. Existen múltiples revisiones del método implementadas en winBUGS y JAGS.

En resumen, el DIC se puede entender como una generalización de AIC y BIC que relaja la asunciones de independencia y certidumbre de los parámetros. El DIC hace una búsqueda del modelo verdadero implementando técnicas de MCMC que aportan una visión más completa de las propiedades de los modelos estadísticos.
