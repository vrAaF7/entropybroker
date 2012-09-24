// SVN: $Id$
class hasher_ripemd160 : public hasher
{
public:
	hasher_ripemd160();
	~hasher_ripemd160();

	int get_hash_size() const;
	void do_hash(unsigned char *in, int in_size, unsigned char *dest);
};
