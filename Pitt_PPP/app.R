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
            
            #Creates a checkbox to allow the user to decide between an unfilled 
            # or filled histogram 
            checkboxInput(inputId = "fill_data",
                               label = "Show filled histogram"),
            
           
             #Selects on what variable to stack the histogram
             radioButtons(inputId = "hist.fill",
                          label = "Pick the variable you would like to fill by:",
                          choices = c("BusinessType", "RaceEthnicity", "Gender", "Veteran", "Lender")
                          ),
         
           
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
                        tabPanel("Bar Graph of PPP Loan Approvals Over Time", plotOutput(outputId = "bar")),
                        tabPanel("Summary Statistics for Zip Code", tableOutput(outputId = "sumstat"))
                                 ),
            
            #creating some space between the tab panel outputs and the data table
            br(), br(), br(),


            
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
        
        #If the user wants a filled histogram, create this plot
        if(input$fill_data) {
        ggplot(data = zip_subset(), aes(x = LoanAmount)) +
            aes_string(fill = input$hist.fill) +
            geom_histogram() +
            xlab("Amount of PPP Loan") +
            ylab("Number of Recipients") +
            ggtitle("What is the Distribution of PPP Loan Amounts?")
        }
        #otherwise, the histogram is plain & unfilled
        else {
            ggplot(data = zip_subset(), aes(x = LoanAmount)) +
                geom_histogram() +
                xlab("Amount of PPP Loan") +
                ylab("Number of Recipients") +
                ggtitle("What is the Distribution of PPP Loan Amounts?")
        }
        
    })
    
    
    
   #creates a bar graph that plots how many loans were approved over time
    output$bar <- renderPlot( {
        
        #calculates how many loans were approved per day
        loans.per.day <- zip_subset() %>%
            mutate(month = format(as.Date(DateApproved, "%m/%d/%Y"), "%m"), year = format(as.Date(DateApproved, "%m/%d/%Y"),"%Y")) %>%
            group_by(month, year) %>%
            summarize(num.loans = n())
        
        ggplot(loans.per.day, aes(x=month, y= num.loans, fill = month)) +
            geom_bar(stat = "identity") +
            xlab("Month in 2020") +
            ylab("Number of Loans Approved") 
        
        
    })
    
    
    
    #creates a summary statistics table for desired zipcode
    output$sumstat <- renderTable({
        
        #makes the Lender column a factor variable
        lend.fact <- factor(zip_subset()$Lender)
        
        #Finds the lender that appears most frequently for the subset of data
        common.lend <- unique(lend.fact)[lend.fact %>% 
                                             match(unique(lend.fact)) %>% 
                                             tabulate() %>% 
                                             which.max()]
        

         zip_sumstat <- zip_subset() %>% 
             summarize("Total Number of Loans" = n(),
                       "Minimum Loan Size" = min(LoanAmount),
                       "Maximum Loan Size" = max(LoanAmount),
                       "Average Loan Size" = mean(LoanAmount),
                       "Most Common Lender" = common.lend) 
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
