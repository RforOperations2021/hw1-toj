#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Loading relevant libraries & data 
library(shiny)
library(DT)
library(tidyverse)
load("pittppp.csv")

ui <- fluidPage(
    
    # Application title
    titlePanel("Pittsburgh PPP Loan Data"),
    
    # Sidebar layout with a input and output definitions --------------
    sidebarLayout(
        
        # Inputs: Select variables to plot ------------------------------
        sidebarPanel(
            
            #Selects Zip Code in Pittsburgh (to be used to filter the data)
            selectInput(inputId = "zip_code",
                        label = "Pittsburgh Zip Code",
                        choices = "" )
        ),
        
        #Outputs
        mainPanel(
            tableOutput("zipTable")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    #Display data table of PPP loans for selected
    output$zipTable <- renderTable({
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
