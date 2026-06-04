private ProgressBar downloadProgressBar;
        private TextView downloadProgressText;
        private Button downloadBtn;

         

        public void AddDownloadButtonStyle2(Object data, String buttonText) {
            final LinearLayout container = new LinearLayout((Context) this);
            container.setOrientation(LinearLayout.VERTICAL);
            LinearLayout.LayoutParams containerParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            containerParams.setMargins(convertSizeToDp(15f), convertSizeToDp(15f), convertSizeToDp(15f), convertSizeToDp(15f));
            container.setLayoutParams(containerParams);

            GradientDrawable containerBg = new GradientDrawable();
            containerBg.setShape(GradientDrawable.RECTANGLE);
            containerBg.setColor(Color.parseColor("#0f021c")); 
            containerBg.setStroke(3, Color.parseColor("#8333d4")); 
            containerBg.setCornerRadii(new float[]{25, 25, 10, 10, 25, 25, 10, 10});
            container.setBackground(containerBg);
            container.setPadding(convertSizeToDp(20f), convertSizeToDp(25f), convertSizeToDp(20f), convertSizeToDp(25f));

            Typeface youssefFont;
            try {
                youssefFont = Typeface.createFromAsset(getAssets(), "fonts/ChrustyRock-ORLA.ttf");
            } catch (Exception e) {
                youssefFont = Typeface.DEFAULT_BOLD;
            }

            downloadBtn = new Button((Context) this);
            downloadBtn.setText(buttonText + "");
            downloadBtn.setTextSize(17f);
            downloadBtn.setTextColor(Color.WHITE);
            downloadBtn.setTypeface(youssefFont); 

            final int[] gradientColors = new int[]{
                Color.parseColor("#6013ad"), 
                Color.parseColor("#310f54"), 
                Color.parseColor("#8333d4")
            };

            final GradientDrawable btnStyle = new GradientDrawable();
            btnStyle.setOrientation(GradientDrawable.Orientation.LEFT_RIGHT);
            btnStyle.setCornerRadius(20); 
            btnStyle.setStroke(6, Color.parseColor("#8333d4"));
            btnStyle.setColors(gradientColors);
            downloadBtn.setBackground(btnStyle);
            downloadBtn.setPadding(convertSizeToDp(22f), convertSizeToDp(16f), convertSizeToDp(22f), convertSizeToDp(16f));

            LinearLayout.LayoutParams btnParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            downloadBtn.setLayoutParams(btnParams);

            final ValueAnimator neonAnimator = ValueAnimator.ofFloat(0f, 1f);
            neonAnimator.setDuration(700);
            neonAnimator.setRepeatCount(ValueAnimator.INFINITE);
            neonAnimator.setInterpolator(new LinearInterpolator());
            neonAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                    @Override
                    public void onAnimationUpdate(ValueAnimator animation) {
                        int first = gradientColors[0];
                        gradientColors[0] = gradientColors[1];
                        gradientColors[1] = gradientColors[2];
                        gradientColors[2] = first;
                        btnStyle.setColors(gradientColors);
                        downloadBtn.invalidate();
                    }
                });
            neonAnimator.start();

            downloadBtn.setOnTouchListener(new View.OnTouchListener() {
                    @Override
                    public boolean onTouch(View v, MotionEvent event) {
                        if (event.getAction() == MotionEvent.ACTION_DOWN) {
                            btnStyle.setStroke(6, Color.parseColor("#310f54")); 
                            downloadBtn.setBackground(btnStyle);
                        } else if (event.getAction() == MotionEvent.ACTION_UP || event.getAction() == MotionEvent.ACTION_CANCEL) {
                            btnStyle.setStroke(6, Color.parseColor("#8333d4")); 
                            downloadBtn.setBackground(btnStyle);
                        }
                        return false;
                    }
                });

            downloadProgressText = new TextView((Context) this);
            downloadProgressText.setTextSize(13f);
            downloadProgressText.setTextColor(Color.WHITE);
            downloadProgressText.setGravity(Gravity.CENTER);
            downloadProgressText.setVisibility(View.GONE);
            downloadProgressText.setTypeface(youssefFont); 

            LinearLayout.LayoutParams textParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            textParams.setMargins(0, convertSizeToDp(15f), 0, convertSizeToDp(10f));
            downloadProgressText.setLayoutParams(textParams);

            downloadProgressBar = new ProgressBar((Context) this, null, android.R.attr.progressBarStyleHorizontal);
            downloadProgressBar.setVisibility(View.GONE);
            downloadProgressBar.setMax(100);

            GradientDrawable progressGradient = new GradientDrawable(
                GradientDrawable.Orientation.LEFT_RIGHT, 
                new int[]{Color.parseColor("#8333d4"), Color.parseColor("#6013ad")}
            );
            progressGradient.setCornerRadius(20f);
            ClipDrawable progressClip = new ClipDrawable(progressGradient, Gravity.LEFT, ClipDrawable.HORIZONTAL);

            GradientDrawable progressBg = new GradientDrawable();
            progressBg.setColor(Color.parseColor("#310f54"));
            progressBg.setCornerRadius(20f);

            Drawable[] layers = new Drawable[]{progressBg, progressClip};
            LayerDrawable layerDrawable = new LayerDrawable(layers);
            layerDrawable.setId(0, android.R.id.background);
            layerDrawable.setId(1, android.R.id.progress);
            downloadProgressBar.setProgressDrawable(layerDrawable);

            LinearLayout.LayoutParams barParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, convertSizeToDp(10f));
            downloadProgressBar.setLayoutParams(barParams);

            container.addView(downloadBtn);
            container.addView(downloadProgressText);
            container.addView(downloadProgressBar); 

            downloadBtn.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        String detectedPackage = getInstalledGamePackage();
                        if (detectedPackage == null) {
                            Toast.makeText(v.getContext(), "❌ Game version not found!", Toast.LENGTH_LONG).show();
                            return;
                        }

                        downloadBtn.setEnabled(false);
                        downloadBtn.setAlpha(0.4f);
                        downloadProgressText.setVisibility(View.VISIBLE);
                        downloadProgressBar.setVisibility(View.VISIBLE);
                        downloadProgressBar.setProgress(0);

                        Toast.makeText(v.getContext(), " FETCHING  PAYBASS", Toast.LENGTH_SHORT).show();

                        fetchFilesFromGitHub();
                    }
                });

            if (data instanceof Integer) 
                pageLayouts[(Integer) data].addView(container);
            else if (data instanceof ViewGroup) 
                ((ViewGroup) data).addView(container);
        }

        private String getInstalledGamePackage() {
            String[] pubgPackages = {
                "com.tencent.ig", "com.pubg.krmobile", "com.pubg.vng", "com.vng.pubgmobile",
                "com.pubg.imobile", "com.rekoo.pubgm", "com.pubg.phmobile", "com.pubg.jp",
                "com.pubg.tw", "com.pubg.cnmobile", "com.pubg.idmobile", "com.pubg.mena", "com.pubg.global"
            };

            PackageManager pm = getPackageManager();
            for (String packageName : pubgPackages) {
                try {
                    pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);
                    return packageName;
                } catch (PackageManager.NameNotFoundException e) {}
            }
            return null;
        }

        private void fetchFilesFromGitHub() {
            new Thread(new Runnable() {
                    @Override
                    public void run() {
                        HttpURLConnection connection = null;
                        try {
                            String safeUrl = getGitHubApiUrl(); 

                            URL url = new URL(safeUrl);
                            connection = (HttpURLConnection) url.openConnection();
                            connection.setRequestMethod("GET");
                            connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                            connection.setConnectTimeout(15000);
                            connection.setReadTimeout(15000);
                            connection.connect();

                            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                                BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                                StringBuilder response = new StringBuilder();
                                String line;
                                while ((line = reader.readLine()) != null) {
                                    response.append(line);
                                }
                                reader.close();

                                JSONArray filesArray = new JSONArray(response.toString());
                                final ArrayList<String> extractedUrls = new ArrayList<>();

                                for (int i = 0; i < filesArray.length(); i++) {
                                    JSONObject fileObject = filesArray.getJSONObject(i);
                                    if (fileObject.getString("type").equals("file")) {
                                        String downloadUrl = fileObject.getString("download_url");
                                        extractedUrls.add(downloadUrl);
                                    }
                                }

                                if (!extractedUrls.isEmpty()) {
                                    final String[] urlsArray = extractedUrls.toArray(new String[0]);
                                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                                            @Override
                                            public void run() {
                                                downloadAndMoveMultipleFiles(urlsArray, 0);
                                            }
                                        });
                                } else {
                                    showDownloadError("No files found  repository.");
                                    resetUiOnError();
                                }
                            } else {
                                showDownloadError(" API Error: " + connection.getResponseCode());
                                resetUiOnError();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            showDownloadError("Failed to connect  securely.");
                            resetUiOnError();
                        } finally {
                            if (connection != null) connection.disconnect();
                        }
                    }
                }).start();
        }

        private void downloadAndMoveMultipleFiles(final String[] downloadUrls, final int index) {
            if (index >= downloadUrls.length) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(Floating.this, "✅ BAYPASS DONE", Toast.LENGTH_LONG).show();
                            downloadBtn.setEnabled(true);
                            downloadBtn.setAlpha(1.0f);
                            downloadProgressText.setVisibility(View.GONE);
                            downloadProgressBar.setVisibility(View.GONE);
                        }
                    });
                return;
            }

            final String detectedPackage = getInstalledGamePackage();

            final String avatarDirPath = "/storage/emulated/0/Android/data/" + detectedPackage + "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Avatar/";
            final String targetDirPath = "/storage/emulated/0/Android/data/" + detectedPackage + "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/";
            final String currentUrl = downloadUrls[index];

            String extractedFileName = "";
            try {
                URL url = new URL(currentUrl);
                String path = url.getPath();
                if (path.contains("?")) {
                    path = path.substring(0, path.indexOf("?"));
                }
                
                extractedFileName = path.substring(path.lastIndexOf('/') + 1);
            } catch (Exception e) {
                extractedFileName = "file_" + System.currentTimeMillis() + ".pak";
            }

            final String fileName = extractedFileName;

            final File avatarDir = new File(avatarDirPath);
            final File targetDir = new File(targetDirPath);

            final File savedAvatarFile = new File(avatarDir, fileName); 
            final File targetFile = new File(targetDir, fileName); 

            if (!avatarDir.exists()) {
                avatarDir.mkdirs();
            }
            if (!targetDir.exists()) {
                targetDir.mkdirs();
            }

            
            if (savedAvatarFile.exists() && savedAvatarFile.length() > 0) {
                new Thread(new Runnable() {
                        @Override
                        public void run() {
                            new Handler(Looper.getMainLooper()).post(new Runnable() {
                                    @Override
                                    public void run() {
                                        downloadProgressBar.setIndeterminate(true);
                                        downloadProgressText.setText("⚡ [Stored] Overwriting: " + fileName + "...");
                                    }
                                });

                            
                            if (moveFileAndOverwrite(savedAvatarFile, targetFile)) {
                                downloadAndMoveMultipleFiles(downloadUrls, index + 1);
                            } else {
                                showDownloadError("Failed to apply file from Avatar: " + fileName);
                                resetUiOnError();
                            }
                        }
                    }).start();
                return; 
            }

            
            new Thread(new Runnable() {
                    @Override
                    public void run() {
                        HttpURLConnection connection = null;
                        BufferedInputStream input = null;
                        BufferedOutputStream output = null;
                        try {
                            URL url = new URL(currentUrl);
                            connection = (HttpURLConnection) url.openConnection();
                            connection.setRequestMethod("GET");
                            connection.setConnectTimeout(25000);
                            connection.setReadTimeout(25000);
                            connection.setInstanceFollowRedirects(true); 
                            connection.setRequestProperty("User-Agent", "Mozilla/5.0");
                            connection.connect();

                            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                                input = new BufferedInputStream(connection.getInputStream());
                                output = new BufferedOutputStream(new FileOutputStream(savedAvatarFile)); 

                                new Handler(Looper.getMainLooper()).post(new Runnable() {
                                        @Override
                                        public void run() {
                                            downloadProgressBar.setIndeterminate(true); 
                                            downloadProgressText.setText("⏳ DOWNLOADING: " + "\n(" + (index + 1) + "/" + downloadUrls.length + ")...");
                                        }
                                    });

                                byte[] buffer = new byte[4096];
                                int bytesRead;

                                while ((bytesRead = input.read(buffer)) != -1) {
                                    output.write(buffer, 0, bytesRead);
                                }

                                output.flush();
                                output.close();
                                input.close();

                                new Handler(Looper.getMainLooper()).post(new Runnable() {
                                        @Override
                                        public void run() {
                                            downloadProgressText.setText("APPLYING PAYBASS ");
                                        }
                                    });

                                
                                if (moveFileAndOverwrite(savedAvatarFile, targetFile)) {
                                    downloadAndMoveMultipleFiles(downloadUrls, index + 1);
                                } else {
                                    showDownloadError("Failed to apply downloaded file to game path: " + fileName);
                                    resetUiOnError();
                                }

                            } else {
                                showDownloadError("Server Error: " + connection.getResponseCode());
                                resetUiOnError();
                            }

                        } catch (final Exception e) {
                            showDownloadError("Connection lost or timeout.");
                            resetUiOnError();
                        } finally {
                            try {
                                if (output != null) output.close();
                                if (input != null) input.close();
                            } catch (Exception ignored) {}
                            if (connection != null) connection.disconnect();
                        }
                    }
                }).start();
        }

        private boolean moveFileAndOverwrite(File sourceFile, File destFile) {
            BufferedInputStream bis = null;
            BufferedOutputStream bos = null;
            try {
                if (destFile.exists()) {
                    destFile.delete(); 
                }
                bis = new BufferedInputStream(new FileInputStream(sourceFile));
                bos = new BufferedOutputStream(new FileOutputStream(destFile));
                byte[] buf = new byte[4096]; 
                int len;
                while ((len = bis.read(buf)) > 0) {
                    bos.write(buf, 0, len);
                }
                bos.flush();
                return true;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            } finally {
                try {
                    if (bis != null) bis.close();
                    if (bos != null) bos.close();
                } catch (Exception ignored) {}
            }
        }

        private void showDownloadError(final String message) {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(Floating.this, "❌ " + message, Toast.LENGTH_LONG).show();
                    }
                });
        }

        private void resetUiOnError() {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        downloadBtn.setEnabled(true);
                        downloadBtn.setAlpha(1.0f);
                        downloadProgressText.setVisibility(View.GONE);
                        downloadProgressBar.setVisibility(View.GONE);
                    }
                });
        }
