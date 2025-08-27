print("Running in background...")

for (i in 1:10) {
  Sys.sleep(1)
  print(i)
}

print("Job is finished.")
