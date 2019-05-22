---
title: "Cosas que conviene saber al usar AIC, DIC y otros criterios de información"
layout: article
---

Una de las herramientas estadísticas que más se usan en ecología son los indicadores de información (AIC, BIC, DIC y muchos otros). Aunque los solemos utilizar como simples herramientas, detrás hay una lógica muy potente e interesante. Entender algo de esa lógica nos puede ayudar bastante. La idea de esta entrada es indagar un poco más en la lógica detrás de los criterios de informaicón, de dónde vienen y cómo se interpretan. 

La idea general es... Necesitamos una manera de elegir (formalmente) entre unas serie de modelos estadísticos que difieren en complejidad y en calidad de ajuste (o capacidad de explicar nuestros datos). Generalmente, cuanto más complejo es un modelo (porque tiene muchas variables, interacciones, etc) mejor describirá el proceso que estamos analizando, pero si es demasiado complejo perderá generalidad (será muy bueno prediciendo los datos para los que está entrenado, pero nada más allá de eso). Asique tenemos un compromiso: queremos un modelo lo suficientemente complejo para que sea una buena descripción de nuestro sistema de estudio, pero no tan complejo como para que no tenga validez general.  

Pues esto es lo que hacen los indicadores de información (medir el balance entre capacidad predictiva y complejidad) y por eso tienen siempre esta forma:

\begin{align}
\ xIC = complejidad - ajuste\\
\end{align}

Donde xIC puede ser AIC (Aikaike Information Criterion), BIC (Bayesian Information Criterion), DIC (Deviance Information Criterion) y muchos otros, aquí sólo vamos a hablar de esos tres. Los dos primeros utilizan Maximum Likelihood como criterio de bondad de ajuste y el número de parámetros como medida de complejidad. El DIC es más sofisticado, trabaja con la distribución a posteriori de los parámetros (que obtiene haciendo MCMC), y mide la complejidad como el número y grado de interrelación entre los parámetros.

### Criterio de Información de Akaike

Algo que en ecología usamos constantemente:

\begin{align}
\ AIC = 2k -  2 \ln(L) \\
\end{align}

Donde k es el número de parámetros y L es el máximo de la función de verosimilitud (Maximum likelihood del modelo). Es decir, según AIC, la bondad de ajuste es el valor de Maximum Likelihood y la complejidad es el número de parámetros. 

La medida de **bondad de ajuste** aquí es 2 ln(L). No vamos a entrar en detalles sobre qué es L (la versimilitud o likelihood), sólo un par de nociones. Primero, L es el producto de las probabilidades de cada dato condicionado al modelo, por lo que L se obtiene multiplicando n valores entre 0 y 1 (o sumando sus logaritmos). Segundo, ln(L) es una función creciente, pero la hacemos decrecer al multiplicarle -1. Así, cuando L tiende a infinito, la expresión -2 ln(L) tiende a un valor muy pequeño. Por lo tanto, el valor de AIC decrece conforme aumenta la bondad de ajuste.

La **complejidad** en el AIC viene dada por k, que es el número de parámetros del modelo. La penalización de 2k del AIC es equivalente a hacer la validación cruzada del modelo dejando un dato fuera (leave one out-cross validation). ¿Qué ocurre si aumentamos el número de parámetros, k, y eso no se traduce en un incremento de la verosimilitud, L? Me explico, qué pasa si hacemos más complicado el modelo sin que con ello consigamos que explique mejor nuestros datos. Pues que AIC aumentará del orden de 2 ∆k. Por tanto, diferencias de AIC de aproximadamente 2 entre modelos que difieren en un solo parámetro indican que la verosimilitud del modelo no cambia a pesar de que añadamos o quitemos un parámetro. Si lo que estamos haciendo es quitar parámetros para simplificar el modelo, podemos establecer como criterio dejar de quitar variables cuando el decremento de AIC < 2, lo que indica cambios no significativos en la bondad de ajuste del modelo. 

Estas son las razones por las, cuando comparamos modelos, elegimos el que tiene menor AIC y establecemos el criterio de que cambios de AIC por debajo de 2 no son "significativos".

Entonces por qué hay otros indicadores? No es suficiente con el AIC? El mayor problema es utilizar k como única medida de complejidad, ya que su efecto suele ser minúsculo comparado con el valor que toma -2ln(L). En otras palabras, perdonamos que el modelo sea muy complejo siempre y cuando tenga muchos datos para avalar cada parámetro. Esto se debe a que el AIC tiene como objetivo seleccionar el modelo que mejor hace predicciones dentro de un set de datos. Esto es muy conservador, pero puede que no sea lo que queremos en todo momento.

### Criterio de Información Bayesiano

Se parece al AIC, pero tiene diferencias clave:

\begin{align}
\ BIC = k \ln(n) -  2 \ln(L) \\
\end{align}

De nuevo k es el número de parámetros, L es el Maximum Likelihood y n es el número de datos. Sin embargo ahora la medida de la complejidad incorpora tanto k como ln(n). Por lo tanto, los efectos de aumentar la complejidad ya no son tan minúsculos, porque ahora el número de parámetros k no aparece sólo, sino como un factor que multiplica al tamaño muestral. Es decir, BIC penaliza más la complejidad que AIC, busca el modelo más abstracto, más sencillo y que hace predicciones en un contexto más amplio. Por su parte AIC dará con un modelo más complejo y pragmático que hace predicciones con mayor detalle dentro de nuestros propios datos.

Con todo, tanto AIC como BIC dan una medida demasiado simple de la complejidad. Por ejemplo, si usamos modelos complejos, no lineales, si hay interacciones entre parámetros, colinealidad o estructuras jerárquicas de factores aleatorios, esto de medir la complejidad de manera aditiva con el número de parámetros se queda corto. 

### Criterio de Información de la Devianza

El DIC (Deviance Information Criterion) es una versión generalizada del AIC y del BIC que incorpora la batería de procedimientos y la lógica de la estadística bayesiana. El DIC utiliza cadenas de Monte Carlo para calcular la distribución a posteriori de los parámetros. Luego trabaja con estas distribuciones (no sólo con un valor puntual del parámetro) para medir la complejidad y la bondad de ajuste. Primero, la bondad de ajuste será el promedio de la devianza total del modelo:

\begin{align}
\ \bar{D}(\theta) = -2 \int \log(p(y|\theta)) \, d\theta\\
\end{align}

Lo interesante es cómo mide la complejidad. Piensa que si los parámetros de un modelo están muy relacionados entre ellos, las cadenas MCMC tendrán complicado dar con el valor del parámetro que maximiza el likelihood. Seguramente estarán probando unos y otros valores dando lugar a unas distribuciones amplias, llenas de incertidumbre, con una alta devianza. El DIC utiliza esto para medir la complejidad (no sólo el número de parámetros sino su devianza) y por lo tanto es sensible a las interacciones entre parámetros. El DIC calcula el número efectivo de parámetros, pD, que se define como el promedio de la devianza menos la devianza evaluada en el promedio de los parámetros:

\begin{align}
\ p_D = \bar{D} - D(\bar{\theta})\\
\end{align}

Con ello, el DIC se define como:

\begin{align}
\ DIC = \bar{D}(\theta) + p_D = D(\bar{\theta}) + 2 p_D\\
\end{align}

El número efectivo de parámetros tiene en cuenta simultáneamente el tamaño muestral, la relación (covariación) entre los parámetros, el número de parámetros y el tamaño de los efectos de las variables.

Por supuesto el DIC no está exento de críticas. En concreto, el sistema por el que penaliza el número de parámetros no equivale a una forma de cross-validation como ocurre en el AIC. La forma de corregir esto es multiplicar por un factor el número efectivo de parámetros, tal que el indicador converja al método de leave one out al igual que el AIC. Existen múltiples revisiones del método implementadas en winBUGS y JAGS.

En resumen, el DIC se puede entender como una generalización de AIC y BIC que relaja la asunciones de independencia y certidumbre de los parámetros. El DIC hace una búsqueda del modelo verdadero implementando técnicas de MCMC que aportan una visión más completa de las propiedades de los modelos estadísticos.

