require(shiny)
require(shinydashboard)
library(palmerpenguins)

## User interface
ui <- dashboardPage(
  dashboardHeader(title = "Linear model"),
  dashboardSidebar(
    sliderInput(inputId = "intercept", label = "Intercept", min = -1, max = 1, value = 0.8, step = 0.01),
    sliderInput(inputId = "slope", label = "Slope", min = -1, max = 1, value = 0.8, step = 0.01),
    actionButton("fit_linear_model", "Fit linear model")
  ),
  dashboardBody(
    box(
      plotOutput(outputId = "scatterplot")
    )
  )
) # end of ui

## Server
server <- function(input, output) {
  
  # create reactiveValues object to store parameter values
  stored_parameters <- reactiveValues(
    intercept = NULL,
    slope = NULL
  )
  
  # if the user changes the sliders, and update parameter values
  observeEvent(list(input$intercept, input$slope),{
    stored_parameters$intercept <- input$intercept
    stored_parameters$slope <- input$slope
  })
  
  # if the user presses the button, fit a linear model
  observeEvent(input$fit_linear_model,{
    mod <- lm(scale(body_mass_g) ~ scale(flipper_length_mm), penguins)
    stored_parameters$intercept <- coef(mod)[1]
    stored_parameters$slope <- coef(mod)[2]
  })
  
  # plot the results
  output$scatterplot <- renderPlot({
    plot(scale(body_mass_g) ~ scale(flipper_length_mm), penguins, pch = 20, ylab = "Body mass", xlab = "Flipper length", cex.lab = 1.2, cex.axis = 0.8)
    abline(a = stored_parameters$intercept, b=stored_parameters$slope)
  })
} # end of server

## Run the app
shinyApp(ui = ui, server = server)
