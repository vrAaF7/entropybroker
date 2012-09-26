// SVN: $Revision$
#include <string.h>
#include <arpa/inet.h>
#include <string>
#include <arpa/inet.h>
#include <openssl/blowfish.h>

#include "error.h"
#include "random_source.h"
#include "utils.h"
#include "stirrer.h"
#include "stirrer_blowfish.h"

stirrer_blowfish::stirrer_blowfish(random_source_t rs_in) : stirrer(rs_in)
{
}

stirrer_blowfish::~stirrer_blowfish()
{
}

int stirrer_blowfish::get_stir_size() const
{
	return 56; // BLOWFISH
}

int stirrer_blowfish::get_ivec_size() const
{
	return 8;
}

void stirrer_blowfish::do_stir(unsigned char *ivec, unsigned char *target, int target_size, unsigned char *data_in, int data_in_size, unsigned char *temp_buffer, bool direction)
{
	unsigned char temp_key[56];

	if (data_in_size > get_stir_size())
		error_exit("Invalid stir-size %d (expected: %d)", data_in_size, get_stir_size());

	memcpy(temp_key, data_in, data_in_size);
	if (data_in_size < 4) // minimum blowfish key size
	{
		// these generated bytes are not counted in the entropy
		// estimation
		get_random(rs, &temp_key[data_in_size], 4 - data_in_size);

		data_in_size = 4;
	}

	BF_KEY key;
	BF_set_key(&key, data_in_size, temp_key);
	int ivec_offset = 0;
	BF_cfb64_encrypt(target, temp_buffer, target_size, &key, ivec, &ivec_offset, direction ? BF_ENCRYPT : BF_DECRYPT);
	memcpy(target, temp_buffer, target_size);
}
