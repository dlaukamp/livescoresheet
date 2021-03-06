{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.Overview where

import Import

getOverviewR :: Handler Html
getOverviewR = defaultLayout $
  [whamlet|
    <p><a href=@{FrontendR True}> Frontend  (mit Kari Update)
    <p><a href=@{FrontendR False}> Frontend (ohne Kari Update)
    <p><a href=@{BeamerR}> Beamer (im Moment Frontend mit Kari Update)
    <p><a href=@{AdminR}> Admin
    <p><a href=@{JuryR PLeft}> Seitenkampfrichter Links
    <p><a href=@{JuryR PMain}> Hauptkampfrichter
    <p><a href=@{JuryR PRight}> Seitenkampfrichter Rechts
    <p><a href=@{LivestreaminfoR}> Livestreaminfo
    <p><a href=@{ShowallR}> Showall
    <p><a href=@{TableR}> Table.tex
    <p><a href=@{UrkundenR}> Urkunden.csv
    <p><a href=@{LiftersByLotR}> lifters_by_lot.csv
    <p><a href=@{OPLEntriesR}> entries.csv for OpenPowerlifting
    <p><a href=@{BVDKExportR}> BVDK Export|]
