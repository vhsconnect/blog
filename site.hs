--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid ( mappend )
import Hakyll

--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route idRoute
        compile copyFileCompiler
    match "css/*" $ do
        route idRoute
        compile compressCssCompiler
    match (fromList [ "about.rst", "contact.markdown" ]) $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")
    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler >>= loadAndApplyTemplate "templates/post.html"
            (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls
    -- tags
    create [ "archive.html" ] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx = listField "posts" postCtx (return posts)
                    `mappend` constField "title" "Archives"
                    `mappend` defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls
    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx = listField "posts" postCtx (return posts)
                    `mappend` defaultContext
            getResourceBody >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls
    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" `mappend` defaultContext

-- tags >
--(field "tags" $ return . ) `mappend` dateField "date" "%B %e, %Y" `mappend`
-- defaultContext
--
postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx

config :: Configuration
config = defaultConfiguration { previewPort
    = 8700, destinationDirectory = "./docs" }
