"""
=========================================================================
SYNDICATE CRYPTOGRAPHIC SIGNATURE AUTHORITY & DOCUMENT SECURE SEALER
=========================================================================
Version: v1.0.0 (Production-Grade)
Description: Cryptographically signs and verifies financial documents
             (Client Invoices, Engineer Payout Orders, Deposit Notices)
             using RSA asymmetric key cryptography with SHA-256 hashing.
             Ensures tamper-proof legal protection for syndicate ledgers.
=========================================================================
"""

import json
from datetime import datetime
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.serialization import load_pem_private_key, load_pem_public_key
import base64

class SyndicateSignatureAuthority:
    @staticmethod
    def generate_key_pair():
        """
        Generates a secure 2048-bit RSA Private and Public keypair.
        """
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        public_key = private_key.public_key()
        
        # Serialize Private Key to PEM format
        private_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        # Serialize Public Key to PEM format
        public_pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        return private_pem, public_pem

    @staticmethod
    def sign_payload(private_pem: bytes, payload_dict: dict) -> str:
        """
        Signs a JSON-serializable dictionary payload using the private key
        and SHA-256 hashing. Returns the base64-encoded signature.
        """
        # Canonicalize the JSON payload to ensure consistent serialization
        serialized_payload = json.dumps(payload_dict, sort_keys=True, separators=(',', ':')).encode('utf-8')
        
        private_key = load_pem_private_key(private_pem, password=None)
        
        signature = private_key.sign(
            serialized_payload,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        
        return base64.b64encode(signature).decode('utf-8')

    @staticmethod
    def verify_signature(public_pem: bytes, payload_dict: dict, signature_b64: str) -> bool:
        """
        Verifies a base64-encoded signature against a JSON payload
        and a public key PEM. Returns True if valid, False otherwise.
        """
        try:
            serialized_payload = json.dumps(payload_dict, sort_keys=True, separators=(',', ':')).encode('utf-8')
            signature = base64.b64decode(signature_b64)
            
            public_key = load_pem_public_key(public_pem)
            public_key.verify(
                signature,
                serialized_payload,
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
            return True
        except Exception:
            return False

# Demonstration of the signature authority in action
if __name__ == "__main__":
    print("="*80)
    print("         S.E.P.H. CRYPTOGRAPHIC SIGNATURE AUTHORITY DEMONSTRATION")
    print("="*80)
    
    # 1. Generate keys for Qamishli Branch (QAM)
    print("\n[Step 1] Generating secure RSA 2048-bit keypair for QAM branch...")
    private_pem, public_pem = SyndicateSignatureAuthority.generate_key_pair()
    print("✔ Keypair successfully generated.")
    print("\n--- PRIVATE KEY SNAPSHOT (PEM) ---")
    print(private_pem.decode('utf-8')[:150] + "...\n[TRUNCATED FOR SECURITY]\n..." + private_pem.decode('utf-8')[-50:])
    print("\n--- PUBLIC KEY SNAPSHOT (PEM) ---")
    print(public_pem.decode('utf-8'))
    
    # 2. Compile mock transaction payload
    print("[Step 2] Compiling transaction ledger payload for a Supervision project...")
    mock_payload = {
        "project_id": "SC-QAM-2026-0004",
        "client_name": "جميل عبد الصمد",
        "branch_code": "QAM",
        "invoice_total_usd": 1500.00,
        "payouts": [
            {"engineer_id": "ENG-QAM-CIV-0001", "role": "Civil Practitioner", "net_usd": 479.52},
            {"engineer_id": "ENG-QAM-ARC-0034", "role": "Architect Trainee", "net_usd": 271.73}
        ],
        "syndicate_retentions_usd": 439.37,
        "settled_at": datetime.utcnow().isoformat() + "Z"
    }
    print(json.dumps(mock_payload, indent=2, ensure_ascii=False))
    
    # 3. Securely sign the payload
    print("\n[Step 3] Sealing the ledger payload with the QAM private key...")
    signature = SyndicateSignatureAuthority.sign_payload(private_pem, mock_payload)
    print(f"✔ Cryptographic Seal Generated (Base64):\n{signature}")
    
    # 4. Verify signature (Intact check)
    print("\n[Step 4] Verifying the signature using the public key...")
    is_valid = SyndicateSignatureAuthority.verify_signature(public_pem, mock_payload, signature)
    print(f"Verification Result: {'✅ SUCCESS (The document is fully authentic and untampered)' if is_valid else '❌ FAILED'}")
    
    # 5. Tamper test
    print("\n[Step 5] Security Breach Simulation (Tampering with values)...")
    tampered_payload = mock_payload.copy()
    tampered_payload["invoice_total_usd"] = 1501.00  # Altering by just $1.00!
    print("Modifying invoice total by $1.00... Re-verifying...")
    is_tampered_valid = SyndicateSignatureAuthority.verify_signature(public_pem, tampered_payload, signature)
    print(f"Verification Result: {'✅ VALID' if is_tampered_valid else '❌ CRITICAL SECURE BLOCK (Tampering Detected! Signature is invalid.)'}")
    print("="*80)
