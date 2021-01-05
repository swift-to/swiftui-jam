const HtmlWebpackPlugin = require('html-webpack-plugin')

let data = {
  title: "SwiftUI Jam",
  description: "A weekend code jam to stretch your skills",
  twitter: "SwiftUIJam",
  metaIcon: "/img/SwiftUI-Jam-Logo-Small@2x.png"
}

module.exports = {
  configureWebpack: {
    plugins: [
      new HtmlWebpackPlugin({
        template: 'public/index.ejs',
        templateParameters: data,
        title: data.title,
        meta: {
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
          "og:url": "https://www.swiftui-jam.com"
        }
      })
    ]
  }
}
