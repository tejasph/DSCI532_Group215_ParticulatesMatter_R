
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
library(readr)
library(plotly)
library(zoo)
library(ggplot2)
library(viridis)
source("https://raw.githubusercontent.com/jsleslie/DSCI532_Group215_ParticulatesMatter_R/master/src/utils.R")
source("https://raw.githubusercontent.com/jsleslie/DSCI532_Group215_ParticulatesMatter_R/master/src/tabs.R")

app <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")


pm_df = read_csv("https://raw.githubusercontent.com/jsleslie/DSCI532_Group215_ParticulatesMatter_R/master/data/processed_data.csv",
               col_types = cols_only(index = col_date(),
                                     STATION_NAME = col_factor(),
                                     PARAMETER = col_factor(),
                                     RAW_VALUE = col_double()))

avg_df = read_csv("https://raw.githubusercontent.com/jsleslie/DSCI532_Group215_ParticulatesMatter_R/master/data/processed_baseline_data.csv",
                  col_types = cols_only(index = col_date(),
                                     PARAMETER = col_factor(),
                                     RAW_VALUE = col_double()))



app$layout(htmlDiv(list(
	      htmlDiv(className="row", style=list(backgroundColor="#000000", border='1px solid', padding_left="5"), children= list(
		htmlH3('Pollutants Matter BC – Visualization of Particulate Matter Concentrations',
			style= list(color = "#ffffff", margin_top = 2, margin_bottom = 2)),
		htmlP('This application tracks weighted monthly averages for pollution data collected from different stations across British Columbia. The measured pollutants, PM2.5 and PM10, refer to atmospheric particulate matter (PM) that have a diameter of less than 2.5 and 10 micrometers, respectively.',
			style= list(color = "#ffffff", margin_top = 2, margin_bottom = 2))
	      )),
  dccTabs(id="tabs", value='tab-1', children=list(
    dccTab(label='Joint View', value='tab-1'),
    dccTab(label='Enlarged heatmap', value='tab-2')
    )),
  htmlDiv(id='tabs-content')
  )))

app$callback(output('tabs-content', 'children'),
    params = list(input('tabs', 'value')),
function(tab){
  if(tab == 'tab-1'){
	return(get_first_tab(pm_df, avg_df))
    }
  else if(tab == 'tab-2'){
  return(get_second_tab(pm_df))}
}
)

app$callback(
  # update figure of gap-graph
  output=list(id = 'chart-1', property='figure'),
  
  # based on values of year, continent, y-axis components
  params=list(input(id = 'datarange', property='value'),
	      input(id = 'dropdown1', property='value')),

  # this translates your list of params into function arguments
  function(year_value, location) {
    ggplotly(linechart(pm_df, avg_df, init_locations = location, daterange = year_value)) 
  }
)


app$callback(
  # update figure of gap-graph
  output=list(id = 'chart-2', property='figure'),
  
  # based on values of year, continent, y-axis components
  params=list(input(id = 'datarange', property='value'),
	      input(id = 'dropdown2', property='value'),
	      input(id = 'radio1', property='value')),

  # this translates your list of params into function arguments
  function(year_value, locations, pm_s) {
    g <- ggplotly( barplot(pm_df, pm = pm_s, init_locations = locations, daterange = year_value)) %>%
    layout(dragmode = FALSE) 
  }
)

app$callback(
  # update figure of gap-graph
  output=list(id = 'chart-3', property='figure'),
  
  # based on values of year, continent, y-axis components
  params=list(input(id = 'datarange', property='value'),
	      input(id = 'dropdown2', property='value'),
	      input(id = 'radio1', property='value')),

  # this translates your list of params into function arguments
  function(year_value, locations, pm_s) {
    ggplotly(location_linechart(pm_df, avg_df, pm=pm_s, init_locations = locations, daterange = year_value))
  }
)

app$callback(
  # update figure of gap-graph
  output=list(id = 'chart-4', property='figure'),
  
  # based on values of year, continent, y-axis components
  params=list(input(id = 'radio2', property='value')),

  # this translates your list of params into function arguments
  function(pm_s) {
	ggplotly(heatmap(pm_df, pm=pm_s))
  }
)

app$callback(
  # update figure of gap-graph
  output=list(id = 'chart-heatmap', property='figure'),
  
  # based on values of year, continent, y-axis components
  params=list(input(id = 'heatmap_pm', property='value')),

  # this translates your list of params into function arguments
  function(pm_s) {
	ggplotly(heatmap(pm_df, pm=pm_s))
  }
)
app$run_server(host = "0.0.0.0", port = Sys.getenv('PORT', 8050))
