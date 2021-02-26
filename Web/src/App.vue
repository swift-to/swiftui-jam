<template>
    <div id="main-container">
      <div v-if="currentView == 'home'">
      </div>
      <header v-if="currentView != 'home'" >
        <a href="/">
          <img class="logo" src="/img/SwiftUI-Jam-Logo-Small@2x.png" width="128" height="128" />
          <h1>SwiftUI Jam</h1>
        </a>
      </header>
      
      <div v-if="currentView == 'register'">
          <Register @registrationComplete="goToRegisterConfirmation" />
      </div>

      <div v-if="currentView == 'login'">
          <Login />
      </div>

      <div v-if="currentView == 'confirmation'">
         <h3>Registration complete. You will be contacted soon with more information.</h3>
         <a href="/">Home</a>
      </div>

      <div v-if="currentView == 'gallery'">
         <Gallery />
      </div>

      <div v-if="currentView == 'gallery-item'">
         <GalleryItem v-bind:routingParameters="routingParameters" />
      </div>

      <div v-if="currentView == 'me'">
         <Me 
           v-bind:accessToken="accessToken"
           v-on:unauthorizedResponse="goToLogin" />
         <div>
           <button class="nav-item logout" @click="logout()">Logout</button>
         </div>
      </div>
      
    </div>
</template>

<script>
import Register from './components/Register.vue'
import Me from './components/Me.vue'
import Login from './components/Login.vue'
import Gallery from './components/Gallery.vue'
import GalleryItem from './components/GalleryItem.vue'

export default {
  name: 'App',
  components: {
    Register,
    Me,
    Login,
    Gallery,
    GalleryItem
  },
  data: () => {
    return {
        currentView: 'home',
        validRoutes: ['register', 'confirmation', 'login', 'me', 'gallery', 'gallery-item'],
        routingParameters: [],
        accessToken: null
    }
  },
  created: function() {
    this.evaluteAccess()
    this.evaluteHash(false)
    window.addEventListener("hashchange", () => {
      this.evaluteHash(true)
    })
  },
  methods: {
    evaluteAccess: function() {
      const accessToken = this.findGetParameter("accessToken") || window.localStorage.accessToken
      if (accessToken != null) {
        this.accessToken = accessToken
        window.localStorage.accessToken = accessToken
        this.goToLoggedInHome()
      }
    },
    findGetParameter: function (parameterName) {
        var result = null,
            tmp = [];
        location.search
            .substr(1)
            .split("&")
            .forEach(function (item) {
              tmp = item.split("=");
              if (tmp[0] === parameterName) result = decodeURIComponent(tmp[1]);
            });
        return result;
    },
    evaluteHash: function(shouldReloadIfNotFound) {
      let routeComponents = window.location.hash.replace("#", "").split("/")
      if (this.validRoutes.indexOf(routeComponents[0]) !== -1) {
        if(routeComponents.length > 1) {
          this.routingParameters = routeComponents.slice(1)
        }
        this.navigateTo(routeComponents[0])
      } else if (routeComponents[0] == "" && shouldReloadIfNotFound) {
          window.location.reload()
      }
    },
    goToRegister: function() {
      window.location.hash = "#register"
    },
    goToRegisterConfirmation: function() {
      window.location.hash = "#confirmation"
    },
    goToLoggedInHome: function() {
      window.location.hash = "#me"
    },
    goToLogin: function() {
      this.clearAuthData()
      window.location.hash = "#login" 
    },
    navigateTo: function(viewName) {
      this.currentView = viewName
      let introEl = document.getElementById("intro")
      if (introEl) {
        introEl.remove()
      }
    },
    logout: function() {
      this.clearAuthData()
      window.location.href = "/"
    },
    clearAuthData: function() {
      this.accessToken = null
      delete window.localStorage.accessToken
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

</style>
