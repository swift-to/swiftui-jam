<template>
    <div id="main-container">
      
      <div v-if="currentView == 'home'">
        <nav>
          <a class="nav-item register" @click="goToRegister()" >
            <span>📝 Register</span>
          </a>
        </nav>
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
        currentView: 'home'
    }
  },
  methods: {
    goToRegister: function() {
        this.currentView = 'register'
        document.getElementById("intro").remove()
    },
    goToRegisterConfirmation: function() {
        this.currentView = 'confirmation'
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

nav {
  float: right;
}

.nav-item {
  text-decoration: underline;
}
.nav-item:hover {
  color:coral;
}

.nav-item.register {
  display: inline-block;
  text-decoration: none;
  background-color: #008AC8;
  color: white;
  border-radius: 4pt;
  padding: 4pt 8pt;
  cursor: pointer;
  font-size: 14pt;
  font-weight: bold;
}
.nav-item.register:hover {
  background-color: coral;
}
</style>
