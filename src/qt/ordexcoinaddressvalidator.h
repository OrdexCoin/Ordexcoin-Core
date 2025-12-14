// Copyright (c) 2011-2020 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef ORDEXCOIN_QT_ORDEXCOINADDRESSVALIDATOR_H
#define ORDEXCOIN_QT_ORDEXCOINADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class OrdexCoinAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit OrdexCoinAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

/** OrdexCoin address widget validator, checks for a valid ordexcoin address.
 */
class OrdexCoinAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit OrdexCoinAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

#endif // ORDEXCOIN_QT_ORDEXCOINADDRESSVALIDATOR_H
