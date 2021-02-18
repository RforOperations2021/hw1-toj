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
library(shinythemes)
ppp <- read.csv("pittppp.csv")
zipcodes <- read.csv("allegzips.csv")

ui <- fluidPage(
    
    #Chose theme
    theme = shinytheme("united"),
    
    # Application title
    titlePanel("Pittsburgh Paycheck Protection Program Loan Data"),
    
    # Sidebar layout with a input and output definitions --------------
    sidebarLayout(
        
        # Inputs: Select variables to plot ------------------------------
        sidebarPanel(
            
            #Selects Zip Code in Pittsburgh (to be used to filter the data)
            selectInput(inputId = "zip_code",
                        label = "Choose a zip code:",
                        choices = zipcodes$Zips)
        ),
        
        #Outputs
        mainPanel(
            dataTableOutput("zipTable")
        )
    )
)

# Define server logic 
server <- function(input, output) {
    
    #Create a subset of the data filtering for the selected zip code ---------------------------
    zip_subset <- reactive({
        req(input$zip_code)
        filter(ppp, Zip %in% input$zip_code)
    })
    
    #Display data table of PPP loans for selected zip code -------------------------------------------
    output$zipTable <- DT::renderDataTable({
        DT::datatable(data = zip_subset(),
                      rownames = FALSE)

    })
}

# Run the application 
shinyApp(ui = ui, server = server)
