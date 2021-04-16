require(shiny)
require(shinydashboard)
require(nls2)

logistic_model <- function(a, b, c, x){
  y <- c / (1 + exp(a - b*x))
  return(y)
}

x <- rlnorm(500, 2, 0.3)
a_0 <- 4.2
b_0 <- 0.89
c_0 <- 3.5
y <- logistic_model(a_0, b_0, c_0, x) + rnorm(500, 0, 0.2)
y[y<0] <- abs(y[y<0])
simulated_data <- data.frame(mass=y, age=x)

## User interface
ui <- dashboardPage(
  dashboardHeader(title = "Nonlinear model"),
  dashboardSidebar(
    sliderInput(inputId = "a", label = "Parameter a", min = -5, max = 5, value = 1, step = 0.01),
    sliderInput(inputId = "b", label = "Parameter b", min = 0, max = 1, value = 0.5, step = 0.01),
    sliderInput(inputId = "c", label = "Parameter c", min = 0, max = 4, value = 1, step = 0.01),
    actionButton("fit_nls", "Fit nonlinear model")
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
    a = 2,
    b = 1,
    c = 1
  )
  
  # if the user changes the sliders, and update parameter values
  observeEvent(list(input$a, input$b, input$c),{
    stored_parameters$a <- input$a
    stored_parameters$b <- input$b
    stored_parameters$c <- input$c
  })
  
  # if the user presses the button, fit the nonlinear model with the starting values selected by the user 
  observeEvent(input$fit_nls,{
    mod <- nls2(mass ~ logistic_model(a, b, c, age), simulated_data,
                start = list(a=stored_parameters$a, b=stored_parameters$b, c=stored_parameters$c))

    stored_parameters$a <- coef(mod)[1]
    stored_parameters$b <- coef(mod)[2]
    stored_parameters$c <- coef(mod)[3]
  })
  
  # plot the curve
  output$scatterplot <- renderPlot({
    plot(mass ~ age, simulated_data, pch = 20, col = "grey")
    curve(logistic_model(stored_parameters$a, stored_parameters$b, stored_parameters$c, x), 0, 24, lwd = 2, add = T)
  })
} # end of server

## Run the app
shinyApp(ui = ui, server = server)
