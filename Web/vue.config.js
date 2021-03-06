const HtmlWebpackPlugin = require('html-webpack-plugin')

let data = {
  title: "SwiftUI Jam",
  description: "A weekend code jam to stretch your skills",
  twitter: "SwiftUIJam",
  metaIcon: "https://www.swiftuijam.com/img/SwiftUI-Jam-Logo-Small@2x.png"
}

let meta = {
  "description": data.description,
  "keywords": "swiftui,swift,ios,macos,watchos,apple", 

  // Twitter
  "twitter:card": "summary",
  "twitter:site": data.twitter,
  "twitter:title": data.title,
  "twitter:description": data.description,
  "twitter:image": data.metaIcon, 

  // Open Graph 
  "og:title": data.title,
  "og:image": data.metaIcon,
  "og:description": data.description,
  "og:url": "https://www.swiftuijam.com"
}

module.exports = {
  configureWebpack: {
    plugins: [
      new HtmlWebpackPlugin({
        template: 'public/index.ejs',
        templateParameters: data,
        title: data.title,
        meta: meta
      }),
      new HtmlWebpackPlugin({
        filename: "awards-2021.html",
        template: 'public/awards-2021.ejs',
        templateParameters: data,
        title: data.title,
        meta: meta
      })
    ]
  }
}
