build:
	DOCKER_BUILDKIT=1 docker build . --output type=local,dest=.

clean:
	@rm -f u-boot-rockchip.bin

