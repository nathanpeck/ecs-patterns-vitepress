<script setup>
import DarkModeSwitch from './DarkModeSwitch.vue';
</script>

<template>
  <div class="header">
    <a href="/">
      <span class="brand-test">
        <img src="/ship.svg" alt="Brand logo" />Containers on AWS
      </span>
    </a>
    <div class="headerLinks">
      <a href="https://main--prismatic-babka-239bef.netlify.app/">Blog</a>
      <DarkModeSwitch />
    </div>
  </div>
</template>

<style scoped>
.header {
  width: 100%;
  background-color: #f39f86;
  background-image: url(/header-smaller.webp);
  background-size: 600px;
  padding: 20px;
  border-bottom: 5px solid rgb(246, 106, 49);
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.header a {
  text-decoration: none;
}

.headerLinks {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.headerLinks a {

  color: var(--bs-emphasis-color);
  margin-right: 20px;
}

.brand-test {
  display: flex;
  align-items: center;
}

.brand-test {
  color: var(--bs-emphasis-color);
  cursor: pointer;
  text-decoration: none;
  font-size: 2.1em;
  line-height: 54px;
  margin: 0px;
  padding: 0px;
  font-family: Arial, Helvetica, sans-serif;
}

.brand-test img {
  vertical-align: middle;
  margin-right: .2em;
  height: 54px;
}

/** Mini header for mobile */
@media screen and (max-width: 600px) {
  .header {
    width: 100%;
    padding: 5px;
    background: rgb(2, 0, 36);
    background-color: #f39f86;
    background-image: url(/header-smaller.webp);
    background-size: 200px;
    border-bottom: 3px solid rgb(246, 106, 49);
    font-size: 1em;
  }

  .brand-test {
    font-size: 1em;
    line-height: 20px;
  }

  .brand-test img {
    height: 34px;
  }

  .extraLinks {
    display: none;
  }
}
</style>