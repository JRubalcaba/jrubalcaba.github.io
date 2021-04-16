library(shiny)

ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(
      sliderInput(inputId = "M", label = "M, body mass", min = 0, max = 500, value = 100, step = 1),
      sliderInput(inputId = "A", label = "A, gill surface area", min = 0, max = 0.1, value = 0.0304, step = 0.01),
      sliderInput(inputId = "delta", label = "delta, activity level", min = 1, max = 10, value = 1, step = 0.1),
      sliderInput(inputId = "hc", label = "hc, oxygen transfer coefficient", min = 0, max = 1, value = 0.5, step = 0.1),
      sliderInput(inputId = "ox_out", label = "DO, oxygen concentration", min = 0, max = 1, value = 1, step = 0.1),
      sliderInput(inputId = "Km", label = "Km, Michaelis constant", min = 0, max = 10, value = 1, step = 0.1),
      sliderInput(inputId = "E", label = "E, activation energy", min = 0, max = 1, value = 0.6, step = 0.01),
      sliderInput(inputId = "b0", label = "b0, normalization constant", min = 1, max = 5e6, value = 1e10, step = 10)
    ),
    
    mainPanel(
      plotOutput(outputId = "modelPlot")
    )
  )
)

server <- function(input, output, session) {
  
  output$modelPlot <- renderPlot({
    
    MetRate <- function(Tw, M, E, A, hc, Km, b0, delta, ox_out){

      ox_in <- -(A*hc*Km - A*hc*ox_out + (delta * b0 * M^(3/4) * exp(-E/(8.61e-05*(273+Tw)))) - sqrt(A^2*hc^2*(ox_out^2 + Km^2) + 2*A^2*hc^2*ox_out*Km - 2*A*hc*ox_out*(delta * b0 * M^(3/4) * exp(-E/(8.61e-05*(273+Tw)))) + 2*A*hc*(delta * b0 * M^(3/4) * exp(-E/(8.61e-05*(273+Tw))))*Km + (delta * b0 * M^(3/4) * exp(-E/(8.61e-05*(273+Tw))))^2)) / (2*A*hc)
      actual_met_rate <- delta * b0 * M^(3/4) * exp(-E/(8.61e-05*(Tw+273))) * ox_in / (ox_in + Km)
      return(actual_met_rate)
    }
    
    M = input$M      # Body mass
    A = input$A      # Gill surface area
    delta = input$delta # Activity level
    hc = input$hc       # oxygen transfer coefficient# activity level
    ox_out = input$ox_out # oxygen concentration
    Km = input$Km     # michaelis constant
    E = input$E       # activation energy
    b0 = input$b0     # normalization constant
    
    Tw <- seq(5, 40, length.out = 100)
    
    mO2 <- MetRate(Tw=Tw, M=M, E=E, A=A, hc=hc, Km=Km, b0=b0, delta=delta, ox_out=ox_out)
    plot(mO2 ~ Tw, type = "l", cex.axis = 0.8, cex.lab = 1.2, ylab = "Metabolic rate", xlab = "Water temperature")
  })
}

shinyApp(ui, server)

