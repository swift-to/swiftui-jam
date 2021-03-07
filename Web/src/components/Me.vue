<template>
  <div class="me">

    <div class="home" v-if="state == 'home'">
      <div class="my-info">
        <h3>My Info</h3>
        <dl>
          <dt>Name</dt>
          <dd>{{user.name}}</dd>
          <dt>Registration Type</dt>
          <dd>{{user.type}}</dd>
        </dl>
        <div v-if="user.team != null">
          <dl>
            <dt>Team Name</dt>
            <dd>{{user.team.name}}</dd>
            <dt>Members ({{user.team.members.length}})</dt>
            <dd>
              <ul>
                <li v-for="teamMember in user.team.members" v-bind:key="teamMember.id">{{teamMember.name}}</li>
              </ul>
            </dd>
          </dl>
        </div>
        <div v-if="user.address.country != null">
          <h3>Address</h3>
          <dl>
            <dt>Street</dt>
            <dd>{{user.address.street}}</dd>
            <dt>Street 2</dt>
            <dd>{{user.address.street2}}</dd>
            <dt>City</dt>
            <dd>{{user.address.city}}</dd>
            <dt>State</dt>
            <dd>{{user.address.state}}</dd>
            <dt>Postal Code</dt>
            <dd>{{user.address.postalCode}}</dd>
            <dt>Country</dt>
            <dd>{{user.address.country}}</dd>
          </dl>
        </div>

        <div v-if="submission != null">
          <h3>Submission</h3>
          <dl>

            <dt>App Name</dt>
            <dd>{{submission.name}}</dd>
            <dt>Description</dt>
            <dd>{{submission.description}}</dd>
            <dt>Jam Code Git Repo URL</dt>
            <dd>{{submission.repoUrl}}</dd>
            <dt>Lastest Git Repo URL</dt>
            <dd>{{submission.latestRepoUrl}}</dd>
            <dt>Download URL</dt>
            <dd>{{submission.downloadUrl}}</dd>
            <dt>Blog URL</dt>
            <dd>{{submission.blogUrl}}</dd>
            <dt>Credits</dt>
            <dd>{{submission.credits}}</dd>
            <dt>Images</dt>
            <dd>Count: {{submission.images.length}}</dd>

          </dl>
        </div>
      </div>

      <div class="actions">
        <h3>Actions</h3>
        <button 
          class="nav-item" 
          @click="state = 'edit'"
          >📝 Update Personal Info</button>
        <!-- <button class="nav-item">🤫 Create/Update Password</button> -->
        
        <br />

        <!-- <button 
          class="nav-item" 
          @click="state = 'edit-team-name'"
          v-if="user.type == 'teamCaptain'"
          >🆔 Change Team Name</button>

        <button 
          class="nav-item" 
          @click="state = 'change-team'"
          v-if="user.type != 'teamCaptain'"
          >👥 Change Team</button> -->

        <br />
      
        <button class="nav-item">
          <a href="https://discord.gg/YBD2Shqgqc">💬 Join Discord Chat</a>
        </button>

        <br />

        <!-- <button 
          class="nav-item" 
          @click="state = 'submit'"
          v-if="user.type == 'teamCaptain' && submission == null"
          >⏫ Submit your App</button> -->

        <button 
          class="nav-item" 
          @click="state = 'update-submission'"
          v-if="user.type == 'teamCaptain' && submission != null"
          >🔼 Update your Submission</button>
      </div>
    </div>

    <div class="update-info" v-if="state == 'edit'">
      
      <form>
         <label for="name">Name</label>
         <input type="text" name="name" id="name" v-model="user.name">

         <label for="street">Street</label>
         <input type="text" name="street" id="street" v-model="user.address.street">
         <label for="street2">Street 2</label>
         <input type="text" name="street2" id="street2" v-model="user.address.street2">
         <label for="city">City</label>
         <input type="text" name="city" id="city" v-model="user.address.city">
         <label for="state">State</label>
         <input type="text" name="state" id="state" v-model="user.address.state">
         <label for="postalCode">Postal Code</label>
         <input type="text" name="postalCode" id="postalCode" v-model="user.address.postalCode">
         <label for="country">Country</label>
         <select name="country" id="country" v-model="user.address.country">
            <option value="CA">Canada</option>
            <option value="US">United States</option>
         </select>
      </form>
      <div>
        <strong class="warning">Please note that for budgetary reasons we can only mail out stickers to participants in Canada and USA, but we are sincerely grateful for our international participants ❤️</strong>
      </div>
      <button class="nav-item" type="submit" @click="updatePersonalInfo()">Submit</button>
    </div>

    <!-- <div v-if="state == 'edit-team-name'">
      <EditTeamName 
        v-bind:user="user" 
        v-bind:accessToken="accessToken"
        v-on:editComplete="editComplete"
        v-on:unauthorizedResponse="onUnauthedResponse" />
    </div> -->

    <!-- <div v-if="state == 'change-team'">
      <ChangeTeam 
        v-bind:user="user" 
        v-bind:accessToken="accessToken"
        v-on:editComplete="editComplete"
        v-on:unauthorizedResponse="onUnauthedResponse" />
    </div> -->

    <!-- <div v-if="state == 'submit'">
      <Submit 
        v-bind:accessToken="accessToken"
        v-on:newSubmissionCreated="newSubmissionCreated"
        v-on:unauthorizedResponse="onUnauthedResponse" />
    </div> -->

    <div v-if="state == 'update-submission'">
      <UpdateSubmission 
        v-bind:accessToken="accessToken"
        v-bind:submission="submission"
        v-on:submissionNeedsReload="loadSubmissionInfo"
        v-on:editComplete="editComplete"
        v-on:unauthorizedResponse="onUnauthedResponse" />
    </div>

  </div>
</template>

<script>
// import EditTeamName from './EditTeamName.vue'
// import ChangeTeam from './ChangeTeam.vue'
// import Submit from './Submit.vue'
import UpdateSubmission from './UpdateSubmission.vue'

export default {
  name: 'Me',
  components: {
    // EditTeamName,
    // ChangeTeam,
    // Submit,
    UpdateSubmission
  },
  props: ['accessToken'],
  data: () => {
    return { 
      state: 'home',
      user: {
        id: "",
        name: "",
        type: "", 
        team: null,
        address: { }
      },
      submission: null
    }
  },
  created: function() {
    console.log('my access token', this.accessToken)
    this.loadMeInfo()
    this.loadSubmissionInfo()
  },
  computed: {},
  methods: {
    newSubmissionCreated: function () {
      this.loadSubmissionInfo(() => {
        this.state = "update-submission"
      })
    },
    editComplete: function() {
      this.state = 'home'
      this.loadMeInfo()
      this.loadSubmissionInfo()
    },
    loadMeInfo: function() {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.user = JSON.parse(xhr.responseText)
          if (!this.user.address) {
            this.user.address = {}
          }
        }
        else if(xhr.status == 401) {
          this.$emit('unauthorizedResponse')
        }
        else {
          alert(xhr.responseText)
        }
      }
      xhr.open('GET', process.env.VUE_APP_BASE_API_URL + '/api/me')
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
      xhr.send()
    },
    updatePersonalInfo: function() {

      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.state = 'home'
          this.loadMeInfo()
        } 
        else if(xhr.status == 401) {
          this.$emit('unauthorizedResponse')
        }
        else {
          alert(xhr.responseText)
        }
      }

      xhr.open('PATCH', `${process.env.VUE_APP_BASE_API_URL}/api/me`)
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
      xhr.send(JSON.stringify({
        name: this.user.name,
        address: {
          street: this.user.address.street,
          street2: this.user.address.street2,
          city: this.user.address.city,
          state: this.user.address.state,
          postalCode: this.user.address.postalCode,
          country: this.user.address.country
        }
      }))
    },
    loadSubmissionInfo: function(completion) {
      var xhr = new XMLHttpRequest();
      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          console.log(xhr.response)
          this.submission = JSON.parse(xhr.responseText)
          if (completion) {
            completion()
          }
        }
        else if(xhr.status == 401) {
          this.$emit('unauthorizedResponse')
        }
      }
      xhr.open('GET', process.env.VUE_APP_BASE_API_URL + '/api/me/submission')
      xhr.setRequestHeader("Authorization", `Bearer ${this.accessToken}`)
      xhr.send()
    },
    onUnauthedResponse: function() {
      this.$emit('unauthorizedResponse')
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.actions, .my-info {
  float: left;
  padding: 0 20pt;
}

.actions

dl {
  margin-left: 20pt;
}

dt {
  font-weight: bold;
}

</style>
