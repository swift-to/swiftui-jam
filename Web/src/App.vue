<template>
    <div id="main-container">
      
      <div v-if="currentView == 'home'">
          <a class="nav-item" @click="goToRegister()" >
            <h3>Register</h3>
          </a>
      </div>
      
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

.nav-item {
  text-decoration: underline;
}
.nav-item:hover {
  color:coral;
}
</style>
