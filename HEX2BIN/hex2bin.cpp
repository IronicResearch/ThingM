#include <stdio.h>
#include <string>
#include <errno.h>

// convert .hex file to .bin file
int hex2bin(std::string &hexfile, std::string &binfile)
{
	FILE* fhex = fopen(hexfile.c_str(), "r");
	FILE* fbin = fopen(binfile.c_str(), "w");
	char str[48];
	short buf[16];
	int count, offset, pad, hex, sum;

	if (fhex == NULL) {
		printf("unable to open hexfile: %s\n", hexfile.c_str());
		return -ENOENT;
	}

	if (fbin == NULL) {
		printf("unable to open binfile: %s\n", binfile.c_str());
		return -ENOENT;
	}

	while (!feof(fhex)) {
		for (int i = 0; i < sizeof(str); i++) {
			fread(&str[i], 1, 1, fhex);
			if (str[i] == '\n')
				break;
		}

		memset(buf, 0, sizeof(buf));
		sscanf(str, ":%02x%04x%02x", &count, &offset, &pad);
		printf("%02x %04x %02x ", count, offset, pad);
		sum = 0;
		for (int i = 0, j = 9; i < count; i++, j+=2) {
			sscanf(&str[j], "%02x", &hex);
			buf[i] = hex;
			sum += hex;
			sum %= 256;
			printf("%02x ", hex);
		}
		printf("%02x\n", sum);	

		fwrite(buf, sizeof(short), 16, fbin);
	}

	fclose(fhex);
	fclose(fbin);
	return 0;
}

int main(int args, char* argv[])
{
	int ret = 0;
	std::string hexfile, binfile;

	if (args < 2) {
		printf("usage: hex2bin <hexfile> <binfile>\n");
		return -EINVAL;
	}

	hexfile = argv[1];
	if (args == 3)
		binfile = argv[2];
	else
		binfile = hexfile.substr(0, hexfile.rfind(".HEX")) + ".BIN";

	printf("HEX file: %s\n", hexfile.c_str());
	printf("BIN file: %s\n", binfile.c_str());

	ret = hex2bin(hexfile, binfile);

	return ret;
}
