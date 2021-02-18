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
                        choices = zipcodes$Zips),
            
            #Selects on what variable to stack the histogram
            radioButtons(inputId = "hist.fill",
                         label = "Pick the variable you would like to fill by:",
                         choices = c("BusinessType", "RaceEthnicity", "Gender", "Veteran", "Lender")),
            
            #creates download button for users
            downloadButton(outputId = "downloadData",
                           label = "Download"
                           )
        ),
        
    
        #Outputs
        mainPanel(
            
            #Output: Tabset with Plots
            tabsetPanel(type = "tabs",
                        tabPanel("Histogram", plotOutput(outputId = "hist")),
                        tabPanel("Diverging Bar Graph", plotOutput(outputId = "divbar"),
                        tabPanel("Summary Statistics for Zip Code", plotOutput(outputId = "sumstat"))
                                 )
                
            ),
            
            
            dataTableOutput(outputId = "zipTable")
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

    #creating histogram of overall Pittsburgh PPP Loan data relative to selected zip code
    output$hist <- renderPlot({
        ggplot(data = zip_subset(), aes(x = LoanAmount)) +
            aes_string(fill = input$hist.fill) +
            geom_histogram() +
            xlab("Amount of PPP Loan") +
            ylab("Number of Recipients") +
            ggtitle("What is the Distribution of PPP Loan Amounts?")
        
    })
    
    # #creating a diverging bar plot
    # ppp$loan.nums <- ppp %>% 
    #     as.numeric(LoanAmount)
    # avg_loan <- ppp %>% 
    #     mean(loan.nums)
    # ppp$normalloan <- ifelse(ppp$LoanAmount < avg_loan, "below", "above")
    # 
    # output$divbar <- renderPlot({
    #     ggplot(ppp, aes(x= input$zip_code, y=normalloan)) +
    #         geom_bar(stat = "identity") + #aes(fill=normalloan)) +
    #         scale_fill_manual(name = "Loan Size",
    #                           labels = c("Above Average", "Below Average"),
    #                           values = c("above"="#00ba38", "below"="#f8766d")) #+
    #         #coord_flip()
    #     
    # })
    
    
    #creates a summary statistics table
    output$sumstat <- renderTable({
        
    })
    
    #Display data table of PPP loans for selected zip code -------------------------------------------
    output$zipTable <- DT::renderDataTable({
        DT::datatable(data = zip_subset(),
                      rownames = FALSE)

    })
    
    #Creates the downloadable csv of the user's requested dataset
    output$downloadData <- downloadHandler(
        filename =  function() {
            paste(input$zip_code, "_PPPLoans.csv", sep = "")
        },

        content = function(file) {
            write.csv(zip_subset(), file, row.names = FALSE)
        }
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
