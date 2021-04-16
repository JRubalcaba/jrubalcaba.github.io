library(shiny)

## User interface
ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(
      sliderInput(inputId = "pch", label = "Point type", min = 1, max = 21, value = 20, step = 1),
      sliderInput(inputId = "cex", label = "Point size", min = 1, max = 50, value = 1, step = 0.1),
      sliderInput(inputId = "cex.lab", label = "Axis label size", min = 0, max = 10, value = 1.2, step = 0.1),
      sliderInput(inputId = "cex.axis", label = "Axis text size", min = 0, max = 10, value = 0.8, step = 0.1),
      sliderInput(inputId = "lwd", label = "Line width", min = 0, max = 10, value = 1, step = 0.1)
    ),
    
    mainPanel(
      plotOutput(outputId = "scatterplot")
    )
  )
) # end of ui

## Server
server <- function(input, output, session) {
  
  output$scatterplot <- renderPlot({
    plot(body_mass_g ~ flipper_length_mm, penguins, 
         pch = input$pch, 
         cex = input$cex,
         ylab = "Body mass (g)", 
         xlab = "Flipper length (mm)",
         cex.lab = input$cex.lab, 
         cex.axis = input$cex.axis)
    
    mod <- lm(body_mass_g ~ flipper_length_mm, penguins)
    abline(mod, lwd = input$lwd)

  })
}

shinyApp(ui, server)




