<template>
  <div class="content">
    <div class="card content-card">
      <div class="card-body">
        <Content />
      </div>
    </div>
  </div>
</template>

<style scoped>
.content {
  flex: 1;
  margin-top: 20px;
  min-width: 500px;
  max-width: 1100px;
  margin-bottom: 100px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}

.card-body {
  padding-top: 30px;
  padding-left: 40px;
  padding-right: 40px;
}
</style>