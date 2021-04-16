library(shiny)
require(palmerpenguins)

## User interface
ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(

      
    ),
    
    mainPanel(
      plotOutput(outputId = "scatterplot")
    )
  )
) # end of ui

## Server
server <- function(input, output, session) {
  
  output$scatterplot <- renderPlot({
    
    plot(body_mass_g ~ flipper_length_mm, penguins, pch = 20, ylab = "Body mass (g)", xlab = "Flipper length (mm)", cex.lab = 1.2, cex.axis = 0.8)
    mod <- lm(body_mass_g ~ flipper_length_mm, penguins)
    abline(mod)

  })
} # end of server

shinyApp(ui, server)










