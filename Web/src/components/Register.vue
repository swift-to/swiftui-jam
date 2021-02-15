<template>
  <div class="register">
    <h1>Register</h1>
    <form>

      <h3 style="color: red">***Registration is now closed***</h3>

      <!-- <label for="registerAs">Register As:</label>
      <select name="registerAs" id="registerAs" v-model="registerAs">
        <option value="team-captain">Team Captain/Solo Programmer</option>
        <option value="team-member">Team Member</option>
        <option value="floater">Floating Designer</option>
        <option value="assigned-programmer">Randomly Assigned Team Programmer</option>
      </select>

      <label for="name">Name</label>
      <input type="text" name="name" id="name" v-model="formData.name">

      <label for="email">Email</label>
      <input type="email" name="email" id="email" v-model="formData.email">

      <div v-if="registerAs == 'team-captain'">
          <label for="newTeamName">New Team Name</label>
          <input type="text" name="newTeamName" id="newTeamName" v-model="formData.newTeamName">
          <label for="requiresFloater">Requesting Floating Designer?</label>
          <select name="requiresFloater" id="requiresFloater" v-model="formData.requiresFloater">
            <option v-bind:value="true">Yes</option>
            <option v-bind:value="false">No</option>
          </select>
      </div>

      <div v-if="registerAs == 'team-member'">
          <label for="existingTeamId">Select the team you are joining</label>
          <select name="existingTeamId" id="existingTeamId" v-model="formData.existingTeamId">
            <option v-for="team in teams" v-bind:key="team.id" :value="team.id">{{team.name}}</option>
          </select>
      </div>

      <div v-if="registerAs == 'assigned-programmer'">
        <label for="notes">Tell us about yourself.
          <br />What is your skill level?
          <br />What would you like to accomplish during the jam?
        </label>
        <textarea name="notes" id="notes" v-model="formData.notes"></textarea>
      </div>

      <br/><br/>

      <button v-if="!isProcessing && isValid" type="submit" @click="register()">Submit</button>

      <div v-if="!isValid">
        <strong class="warning">Complete the form to continue</strong>
      </div>

      <div v-if="isProcessing">
        <strong>Processing...</strong>
      </div> -->

    </form>
  </div>
</template>

<script>
export default {
  name: 'Register',
  data: () => {
    return {
      registerAs: 'team-captain',
      isProcessing: false,
      teams: [],
      formData: {
        name: null,
        email: null,
        newTeamName: null,
        existingTeamId: null,
        requiresFloater: false
      }
    }
  },
  created: function() {
    this.loadTeams()
  },
  computed: {
    isValid: function() {
      if(
        this.formData.name == null 
        || this.formData.name.length == 0
        || this.formData.email == null
        || this.formData.email.length == 0
        ) {
          return false
        }

        if (this.registerAs == "team-captain" && (
            this.formData.newTeamName == null 
            || this.formData.newTeamName.length == 0
          )) {
            return false
        }
        else if (this.registerAs == "team-member" && this.formData.existingTeamId == null) {
            return false
        }

        return true
    }
  },
  methods: {
    loadTeams: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.teams = JSON.parse(xhr.responseText)
        } else {
          alert(xhr.responseText)
        }
      }
      xhr.open('GET', process.env.VUE_APP_BASE_API_URL + '/api/teams')
      xhr.send()
    },
    register: function () {
      console.log("register", JSON.stringify(this.formData))
      const self = this
      self.isProcessing = true

      let path = "register-"

      switch (this.registerAs) {
        case "team-captain":
          path += "captain"
          break
        case "team-member":
          path += "team-member"
          break
        case "floater":
          path += "floater"
          break
        case "assigned-programmer":
          path += "assigned-programmer"
          break
        default: 
          console.log("unexpected path")
          return
      }

      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.$emit('registrationComplete')
        } else {
          alert(xhr.responseText)
        }
        self.isProcessing = false
      }

      xhr.open('POST', `${process.env.VUE_APP_BASE_API_URL}/api/${path}`)
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.send(JSON.stringify(this.formData))
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
