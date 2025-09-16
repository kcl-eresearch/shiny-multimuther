# MultiMuTHER Shiny app

This repository contains the code for a Shiny app associated with the [MultiMuTHER study](https://multimuther.sites.er.kcl.ac.uk/).

## Development

Clone this repo with `git clone` and open `multimuther-shiny.Rproj` in RStudio.
You should be automatically prompted to set up your working environment using `renv`.
If not, run `renv::restore()` to restore the environment from the `renv.lock` file.

You can preview the app by opening `app.R` in RStudio and clicking the "Run App" button,
or by sourcing the `app.R` file. 

## Deployment

The app is deployed on the CREATE private cloud platform.
Detailed instructions on how to deploy a Shiny app using CREATE Cloud are available in the [e-Research docs](https://docs.er.kcl.ac.uk/CREATE/cloud/cloud_R_shiny_apps/).

To update the deployed version of the app, you will need to log in to the VM and pull changes from this repo.
Depending on the type of changes, you may need to run `sudo systemctl restart shiny-server` to restart Shiny Server.