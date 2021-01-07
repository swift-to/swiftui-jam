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

       <div v-if="currentView == 'confirmation'">
         <h3>Registration complete. You will be contacted with more information.</h3>
         <a href="/">Home</a>
      </div>
      
    </div>
</template>

<script>
import Register from './components/Register.vue'

export default {
  name: 'App',
  components: {
    Register
  },
  data: () => {
    return {
        currentView: 'home',
        validRoutes: ['register', 'confirmation']
    }
  },
  created: function() {
    this.evaluteHash(false)
    window.addEventListener("hashchange", () => {
      this.evaluteHash(true)
    })
  },
  methods: {
    evaluteHash: function(shouldReloadIfNotFound) {
      let route = window.location.hash.replace("#", "")
      if (this.validRoutes.indexOf(route) !== -1) {
        this.navigateTo(route)
      } else if (route == "" && shouldReloadIfNotFound) {
          window.location.reload()
      }
    },
    goToRegister: function() {
      window.location.hash = "#register"
    },
    goToRegisterConfirmation: function() {
      window.location.hash = "#confirmation"
    },
    navigateTo: function(viewName) {
      this.currentView = viewName
      document.getElementById("intro").remove()
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
