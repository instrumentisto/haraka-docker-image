#!/usr/bin/env bats


@test "Built on correct arch" {
  run docker run --rm --platform $PLATFORM --entrypoint sh $IMAGE -c \
    'uname -m'
  [ "$status" -eq 0 ]
  if [ "$PLATFORM" = "linux/amd64" ]; then
    [ "$output" = "x86_64" ]
  elif [ "$PLATFORM" = "linux/arm64v8" ]; then
    [ "$output" = "aarch64" ]
  elif [ "$PLATFORM" = "linux/arm32v6" ]; then
    [ "$output" = "armv7l" ]
  elif [ "$PLATFORM" = "linux/arm32v7" ]; then
    [ "$output" = "armv7l" ]
  else
    [ "$output" = "$(echo $PLATFORM | cut -d '/' -f2-)" ]
  fi
}


@test "Haraka is installed" {
  run docker run --rm --platform $PLATFORM --entrypoint sh $IMAGE -c \
    'which haraka'
  [ "$status" -eq 0 ]
}

@test "Haraka runs ok" {
  run docker run --rm --platform $PLATFORM --entrypoint sh $IMAGE -c \
    'haraka -o -c /etc/haraka'
  [ "$status" -eq 0 ]
}

@test "Haraka has correct version" {
  run sh -c "cat Dockerfile | grep 'ARG haraka_ver=' | cut -d '=' -f2"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  expected="$output"

  run docker run --rm --platform $PLATFORM --entrypoint sh $IMAGE -c \
    "haraka --version | grep 'Version: ' | cut -d ':' -f2 | tr -d ' '"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  actual="$output"

  [ "$actual" = "$expected" ]
}


@test "APK_INSTALL_PACKAGES installs packages" {
  run docker run --rm --platform $PLATFORM \
                 -e APK_INSTALL_PACKAGES=openssl,rclone \
             $IMAGE apk list
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
  actual="$output"

  run sh -c "printf \"$actual\" | grep -E '^openssl-.*\[installed\]$'"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]

  run sh -c "printf \"$actual\" | grep -E '^rclone-.*\[installed\]$'"
  [ "$status" -eq 0 ]
  [ ! "$output" = '' ]
}
