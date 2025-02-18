% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/class_FNG.R
\name{create_FNG_object}
\alias{create_FNG_object}
\title{Constructor for the FNG (feature neighborhood graph) S4 object}
\usage{
create_FNG_object(
  id = NA_character_,
  dataset_id = NA_character_,
  filepath = NA_character_,
  accessor = NA_character_,
  parent_id = NA_character_,
  record_id = NA_character_,
  edge_metric = NA_character_,
  metric_type = NA_character_
)
}
\arguments{
\item{id}{Main ID of MAMS object}

\item{dataset_id}{Parent dataset ID}

\item{filepath}{Path to the data file}

\item{accessor}{Accessor}

\item{parent_id}{Parent FNG object}

\item{record_id}{Record ID}

\item{edge_metric}{Type of edge metric used}

\item{metric_type}{Details of the edge metric}
}
\value{
a FNG S4 object for use with MAMS
}
\description{
Creates the FID object and populates its subfields
}
