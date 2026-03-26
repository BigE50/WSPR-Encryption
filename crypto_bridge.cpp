#include <vector>
#include <cstdint>
#include <cstring>

#include <cryptopp/aes.h>
#include <cryptopp/modes.h>
#include <cryptopp/hkdf.h>
#include <cryptopp/sha.h>

using namespace CryptoPP;

// ==== CONFIG ====
static const uint8_t KEY[32] = {
    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,
    0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x10,
    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,
    0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,0x20
};

// ==== IV DERIVATION (HKDF) ====
std::vector<uint8_t> derive_iv(uint64_t epoch)
{
    HKDF<SHA256> hkdf;

    std::vector<uint8_t> iv(16);

    uint8_t salt[8];
    for (int i = 0; i < 8; ++i)
        salt[i] = (epoch >> (8 * (7 - i))) & 0xFF;

    const std::string info = "AES-256-CTR Message Initialization Vector";

    hkdf.DeriveKey(
        iv.data(), iv.size(),
        KEY, sizeof(KEY),
        salt, sizeof(salt),
        (const uint8_t*)info.data(), info.size()
    );

    return iv;
}

// ==== AES-CTR ====
void aes_ctr_crypt(uint8_t* data, size_t len, uint64_t epoch)
{
    std::vector<uint8_t> iv = derive_iv(epoch);

    CTR_Mode<AES>::Encryption enc;
    enc.SetKeyWithIV(KEY, sizeof(KEY), iv.data());

    enc.ProcessData(data, data, len);
}

// ==== FORTRAN INTERFACE ====
extern "C" {

void encrypt_wspr_payload(uint8_t* data, uint64_t epoch)
{
    aes_ctr_crypt(data, 11, epoch);
}

void decrypt_wspr_payload(uint8_t* data, uint64_t epoch)
{
    aes_ctr_crypt(data, 11, epoch); // same for CTR
}

}
