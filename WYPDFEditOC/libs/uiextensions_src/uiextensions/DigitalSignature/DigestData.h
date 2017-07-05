/**
 * Copyright (C) 2003-2017, Foxit Software Inc..
 * All Rights Reserved.
 *
 * http://www.foxitsoftware.com
 *
 * The following code is copyrighted and is the proprietary of Foxit Software Inc.. It is not allowed to
 * distribute any parts of Foxit Mobile PDF SDK to third party or public without permission unless an agreement
 * is signed between Foxit Software Inc. and customers to explicitly grant customers permissions.
 * Review legal.txt for additional license and legal information.
 */

#import <Foundation/Foundation.h>
#import <openssl/sha.h>
#import <FoxitRDK/FSPDFObjC.h>

// FSCRT_DigestData
class FSCRT_DigestData
{
public:
    FSCRT_DigestData(){}
    ~FSCRT_DigestData(){}
public:
    FSSignature* m_pSig;
    void* m_file;
    const unsigned int* m_pByteRangeArray;
    unsigned int m_sizeofArray;
};

//CFSCRT_DigestContext
class CFSCRT_DigestContext
{
public:
    CFSCRT_DigestContext();
    ~CFSCRT_DigestContext();
public:
    //Initialize and Finalize functions.
    void	Initialize();
    void	Release();
    
    //Set variable m_pDigestData.
    BOOL	SetData(void* file, const unsigned int* byteRangeArray, unsigned int sizeofArray);
    //Get variable m_pDigestData.
    BOOL	GetData(FSCRT_DigestData*& data);
    
public:
    FSCRT_DigestData* m_pDigestData;
    SHA_CTX m_sSHA_CTX;
};

